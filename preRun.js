Module["preRun"].push(function () {
  "use strict";

  FS.mount(IDBFS, {}, "/home");
  FS.syncfs(true, function (err) {
    if (err) {
      console.error(
        "Error loading save data from web browser's IndexedDB storage: " + err
      );
    }
  });

  try {
    FS.stat("/home/web_user");
  } catch {
    FS.mkdir("/home/web_user");
  }
});
