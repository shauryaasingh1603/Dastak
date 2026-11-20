// Dastak offline helper (service worker). Generated into build/web/sw.js by
// tool/make_sw.dart, which fills in VERSION and the file lists from the
// build's precache_manifest.json.
//
// - Keeps the whole app on the phone after the first visit, so the link opens
//   without network. Saved visits live in the browser's database, not here.
// - A new deploy installs alongside the old one; the page then offers
//   "नया संस्करण उपलब्ध है" and switches when the volunteer taps it.
// - Only same-site files are handled: calls to the backend always go to the
//   network.

const VERSION = '__VERSION__';
const CORE = __CORE__;
const ENGINE_CHROMIUM = __ENGINE_CHROMIUM__;
const ENGINE_FULL = __ENGINE_FULL__;
const CACHE = 'dastak-' + VERSION;

// Flutter loads a smaller drawing engine on Chromium browsers (Chrome,
// Edge, Samsung Internet) and the full one elsewhere (Safari, Firefox).
function engineFiles() {
  const brands = (self.navigator.userAgentData && self.navigator.userAgentData.brands) || [];
  const chromium = brands.some((b) => /Chromium/i.test(b.brand));
  return chromium && ENGINE_CHROMIUM.length ? ENGINE_CHROMIUM : ENGINE_FULL;
}

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    await cache.addAll([...CORE, ...engineFiles()]);
    // First install: start serving at once. Later versions wait until the
    // volunteer chooses to update, so nothing reloads in the middle of a visit.
    if (!self.registration.active) await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    for (const name of await caches.keys()) {
      if (name.startsWith('dastak-') && name !== CACHE) await caches.delete(name);
    }
    await self.clients.claim();
  })());
});

self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  if (url.pathname.endsWith('/sw.js')) return;

  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    if (request.mode === 'navigate') {
      // The app has one page: serve the cached copy, so it opens offline.
      return (await cache.match('index.html')) || fetch(request);
    }
    const cached = await cache.match(request, { ignoreSearch: true });
    if (cached) return cached;
    // Anything not cached at install (e.g. another engine variant) is kept
    // the first time it is fetched.
    const response = await fetch(request);
    if (response.ok) cache.put(request, response.clone());
    return response;
  })());
});
