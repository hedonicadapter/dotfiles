const hyprland = await Service.import("hyprland");

export default () => {
  return Widget.Label({
    class_name: "client-title",
    truncate: "end",
    maxWidthChars: 42,
    label: hyprland.active.client.bind("title"),
    setup: (list) =>
      list.hook(
        hyprland,
        (list) => {
          const titleExists = hyprland.active.client.title !== "";
          if (!titleExists) list.hide();
          else list.show();
        },
        "changed",
      ),
  });
};
