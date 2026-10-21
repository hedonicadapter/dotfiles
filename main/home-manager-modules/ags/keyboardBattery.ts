// Battery levels of both halves of a ZMK split keyboard, read from BlueZ GATT.
// The central (right) half exposes its own Battery Service plus a proxy
// Battery Service for the peripheral (left), whose Battery Level carries a
// User Description "Peripheral 0". BlueZ's battery plugin claims both services
// (Battery1 only reflects the first) but still exports them read-only over
// D-Bus — main.conf [GATT] ExportClaimedServices, pinned in configuration.nix.
import Gio from "gi://Gio";
import GLib from "gi://GLib";
import { createState } from "ags";

const DEVICE_NAME = /charybdis/i;
const POLL_SECONDS = 60;

const BLUEZ = "org.bluez";
const DEVICE = "org.bluez.Device1";
const BATTERY = "org.bluez.Battery1";
const CHARACTERISTIC = "org.bluez.GattCharacteristic1";
const DESCRIPTOR = "org.bluez.GattDescriptor1";
const BATTERY_LEVEL_UUID = "00002a19-0000-1000-8000-00805f9b34fb";
const USER_DESCRIPTION_UUID = "00002901-0000-1000-8000-00805f9b34fb";

export type SplitBattery = {
  connected: boolean;
  name: string;
  left: number | null;
  right: number | null;
};

export const [splitBattery, setSplitBattery] = createState<SplitBattery>({
  connected: false,
  name: "",
  left: null,
  right: null,
});

type Half = "left" | "right";
type Objects = Record<string, Record<string, Record<string, any>>>;

Gio._promisify(Gio.DBusConnection.prototype, "call", "call_finish");

const bus = Gio.DBus.system;
let devicePath: string | null = null;
// Characteristic path -> half it reports
let characteristics = new Map<string, Half>();
let scanning: Promise<void> | null = null;
let rescanQueued = false;
let started = false;

function call(path: string, iface: string, method: string, args: GLib.Variant | null, reply: string) {
  return (bus.call(
    BLUEZ,
    path,
    iface,
    method,
    args,
    GLib.VariantType.new(reply),
    Gio.DBusCallFlags.NONE,
    5000,
    null,
  ) as unknown as Promise<GLib.Variant>).then((v) => v.recursiveUnpack());
}

async function readBytes(path: string, iface: string): Promise<Uint8Array> {
  const [value] = await call(path, iface, "ReadValue", new GLib.Variant("(a{sv})", [{}]), "(ay)");
  return value;
}

// ZMK reports 0 for a peripheral it hasn't heard from yet
function level(bytes: Uint8Array | undefined): number | null {
  return bytes && bytes.length > 0 && bytes[0] > 0 ? bytes[0] : null;
}

function publish(patch: Partial<SplitBattery>) {
  const current = splitBattery.peek();
  const next = { ...current, ...patch };
  const keys = Object.keys(next) as (keyof SplitBattery)[];
  if (keys.some((k) => next[k] !== current[k])) setSplitBattery(next);
}

async function labelOf(charPath: string, objects: Objects): Promise<string | null> {
  const descPath = Object.keys(objects).find(
    (p) =>
      p.startsWith(`${charPath}/`) &&
      objects[p][DESCRIPTOR]?.UUID === USER_DESCRIPTION_UUID,
  );
  if (!descPath) return null;

  try {
    return new TextDecoder().decode(await readBytes(descPath, DESCRIPTOR));
  } catch (e) {
    console.error("keyboard battery: reading user description failed", e);
    return null;
  }
}

async function scan() {
  const [objects] = (await call(
    "/",
    "org.freedesktop.DBus.ObjectManager",
    "GetManagedObjects",
    null,
    "(a{oa{sa{sv}}})",
  )) as [Objects];

  const devices = Object.entries(objects).filter(([, ifaces]) =>
    DEVICE_NAME.test(ifaces[DEVICE]?.Alias ?? ifaces[DEVICE]?.Name ?? ""),
  );
  const [path, ifaces] =
    devices.find(([, i]) => i[DEVICE].Connected) ?? devices[0] ?? [null, null];

  devicePath = path;
  characteristics = new Map();

  if (!path || !ifaces[DEVICE].Connected || !ifaces[DEVICE].ServicesResolved) {
    publish({ connected: false, name: ifaces?.[DEVICE].Alias ?? "", left: null, right: null });
    return;
  }

  // Object paths embed handles in hex, so sorting orders them like the device does
  const charPaths = Object.keys(objects)
    .filter(
      (p) =>
        p.startsWith(`${path}/`) &&
        objects[p][CHARACTERISTIC]?.UUID === BATTERY_LEVEL_UUID,
    )
    .sort();

  const labels = await Promise.all(charPaths.map((p) => labelOf(p, objects)));
  if (labels.some((l) => l !== null)) {
    // Proxied peripheral levels carry a description, the central's own doesn't
    charPaths.forEach((p, i) =>
      characteristics.set(p, labels[i]?.startsWith("Peripheral") ? "left" : "right"),
    );
  } else {
    // No descriptions: central's service comes first
    charPaths.forEach((p, i) => characteristics.set(p, i === 0 ? "right" : "left"));
  }

  const values: Partial<Record<Half, number | null>> = {};
  for (const [p, half] of characteristics) {
    values[half] = level(objects[p][CHARACTERISTIC].Value);
    // Already-notifying and similar errors are harmless; the poll covers gaps
    call(p, CHARACTERISTIC, "StartNotify", null, "()").catch(() => {});
  }

  // Characteristic hidden (ExportClaimedServices = no): fall back to Battery1
  if (!("right" in values)) values.right = ifaces[BATTERY]?.Percentage ?? null;

  publish({
    connected: true,
    name: ifaces[DEVICE].Alias ?? "",
    left: values.left ?? null,
    right: values.right ?? null,
  });

  await readLevels();
}

async function readLevels() {
  for (const [p, half] of characteristics) {
    try {
      publish({ [half]: level(await readBytes(p, CHARACTERISTIC)) });
    } catch (e) {
      console.error(`keyboard battery: reading ${half} level failed`, e);
    }
  }
}

// Coalesce bursts of BlueZ signals into one scan at a time
function rescan() {
  if (scanning) {
    rescanQueued = true;
    return;
  }
  scanning = scan()
    .catch((e) => console.error("keyboard battery: scan failed", e))
    .finally(() => {
      scanning = null;
      if (rescanQueued) {
        rescanQueued = false;
        rescan();
      }
    });
}

function onPropertiesChanged(path: string, params: GLib.Variant) {
  const [iface, changed] = params.recursiveUnpack() as [string, Record<string, any>];

  if (iface === CHARACTERISTIC) {
    const half = characteristics.get(path);
    if (half && "Value" in changed) publish({ [half]: level(changed.Value) });
  } else if (iface === BATTERY && path === devicePath && !characteristics.size) {
    if ("Percentage" in changed) publish({ right: changed.Percentage });
  } else if (
    iface === DEVICE &&
    (!devicePath || path === devicePath) &&
    ("Connected" in changed || "ServicesResolved" in changed)
  ) {
    rescan();
  }
}

// Only objects of the keyboard itself, or a newly known keyboard
function onObjectsChanged(signal: string, params: GLib.Variant) {
  const [path, ifaces] = params.recursiveUnpack() as [string, any];
  const ours = devicePath && (path === devicePath || path.startsWith(`${devicePath}/`));
  const newKeyboard =
    signal === "InterfacesAdded" &&
    DEVICE_NAME.test(ifaces[DEVICE]?.Alias ?? ifaces[DEVICE]?.Name ?? "");
  if (ours || newKeyboard) rescan();
}

export function connect() {
  if (started) return;
  started = true;

  bus.signal_subscribe(
    BLUEZ,
    "org.freedesktop.DBus.Properties",
    "PropertiesChanged",
    null,
    null,
    Gio.DBusSignalFlags.NONE,
    (_conn, _sender, path, _iface, _signal, params) => onPropertiesChanged(path, params),
  );

  for (const signal of ["InterfacesAdded", "InterfacesRemoved"]) {
    bus.signal_subscribe(
      BLUEZ,
      "org.freedesktop.DBus.ObjectManager",
      signal,
      "/",
      null,
      Gio.DBusSignalFlags.NONE,
      (_conn, _sender, _path, _iface, _signal, params) => onObjectsChanged(signal, params),
    );
  }

  GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, POLL_SECONDS, () => {
    if (characteristics.size) readLevels();
    else rescan();
    return GLib.SOURCE_CONTINUE;
  });

  rescan();
}
