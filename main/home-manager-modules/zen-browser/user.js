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

// Software video decoding. With VA-API on, a seek or a resume after a long
// pause re-creates the decoder and on this two-GPU box (RX 9060 XT + the
// 9800X3D iGPU, Mesa 26.1) the new decoder comes back with corrupted frames
// (vertical colour bars) and YouTube then drops the stream with a playback
// error. The CPU decodes 4K VP9/AV1 with a few percent of one core, so this
// costs nothing noticeable. `media.ffmpeg.vaapi.enabled` is gone in Gecko
// 152; these two are the switches. Flip the first to true to re-test VA-API
// after a Mesa or Zen update.
user_pref("media.hardware-video-decoding.enabled", false);
user_pref("media.hardware-video-decoding.force-enabled", false);

// Zen writes a second session file next to Firefox's. Each write serialises
// the whole session on the UI thread; profiles show 0.5-3 s hangs that drop
// video frames (zen-browser/desktop#10649, #13266). 15 s default -> 60 s.
user_pref("browser.sessionstore.interval", 60000);

// Second variable, after software decoding removed most of the seek/resume
// failures. QUIC to googlevideo is the usual cause of the remainder in Gecko
// (seek -> new range request stalls or errors); Chrome recovers from the
// same network differently. Wired desktop, so no cost. If a week passes
// with no failures, this stays; if they continue, set it back to true and
// the next suspect is the audio sink after long pauses.
user_pref("network.http.http3.enable", false);
