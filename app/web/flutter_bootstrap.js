{{flutter_js}}
{{flutter_build_config}}

// No Flutter service worker: web/index.html registers sw.js, which keeps the
// whole app on the phone so it opens without network.
_flutter.loader.load();
