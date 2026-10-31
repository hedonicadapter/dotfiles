// Managed by dotfiles (home-manager-modules/zen-browser). Zen reads this at
// every startup, so about:config edits to these keys are reverted.
//
// Why: video playback in Zen stuttered while Chrome was fine. The prefs here
// pin the rendering and decoding path instead of leaving it to "auto", and
// cut the session-store writes that jank Zen's UI thread.

// GPU WebRender, not "auto". Auto drops to Software WebRender whenever the
// Mesa/GPU combination is unknown to Gecko's blocklist (new Mesa on CachyOS,
// RDNA4), and software rendering of 1080p at 240 Hz drops video frames.
// Same pair the Firefox profile already uses.
user_pref("gfx.webrender.all", true);
user_pref("layers.acceleration.force-enabled", true);

// VA-API decode through the system ffmpeg the wrapper puts on LD_LIBRARY_PATH.
// `media.ffmpeg.vaapi.enabled` no longer exists in Gecko 152; this is the switch.
user_pref("media.hardware-video-decoding.enabled", true);
// Left in prefs.js by an earlier attempt. Forcing skips the blocklist *and*
// keeps retrying a failing hardware decoder instead of falling back to
// software; about:support already reports VA-API available without it.
user_pref("media.hardware-video-decoding.force-enabled", false);

// Zen writes a second session file next to Firefox's. Each write serialises
// the whole session on the UI thread; profiles show 0.5-3 s hangs that drop
// video frames (zen-browser/desktop#10649, #13266). 15 s default -> 60 s.
user_pref("browser.sessionstore.interval", 60000);
