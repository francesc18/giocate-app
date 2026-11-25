// Service worker dell'app Giocate: tiene in cache i file così l'app si apre anche senza rete.
// Le giocate sono salvate sul telefono (localStorage) e non passano da qui.
const CACHE = "giocate-v15";
const SHELL = ["./", "index.html", "config.js", "manifest.webmanifest", "icons/icon.svg", "icons/icon-192.png", "icons/apple-touch-icon.png"];

self.addEventListener("install", (e) => {
  e.waitUntil(
    caches.open(CACHE)
      .then((c) => Promise.all(SHELL.map((u) => fetch(u, { cache: "reload" }).then((r) => { if (!r.ok) throw new Error(u); return c.put(u, r); }))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k.startsWith("giocate-") && k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// Con internet carica sempre la versione più recente; la copia salvata serve solo offline
// (o se la rete non risponde entro qualche secondo).
self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin || !url.pathname.startsWith(new URL(self.registration.scope).pathname)) return;
  e.respondWith((async () => {
    const cache = await caches.open(CACHE);
    try {
      const res = await Promise.race([
        fetch(req, { cache: "no-store" }),
        new Promise((_, ko) => setTimeout(() => ko(new Error("lenta")), 4000)),
      ]);
      if (res && res.ok) cache.put(req, res.clone());
      return res;
    } catch (_) {
      const cached = await cache.match(req, { ignoreSearch: true }) || (req.mode === "navigate" ? await cache.match("index.html") : null);
      return cached || fetch(req);
    }
  })());
});
