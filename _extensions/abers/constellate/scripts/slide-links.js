document.addEventListener("DOMContentLoaded", () => {
  const variants = window.quartoSlideVariants;
  if (!variants?.length) return;
  const manifest = document.getElementById("slide-variant-manifest");
  const root = new URL(".", manifest.src);
  const pathUrl = (path) =>
    new URL(path.split("/").map(encodeURIComponent).join("/"), root);
  const pairs = new Map();
  for (const item of variants) {
    const pair = {
      dark: pathUrl(item.dark),
      light: pathUrl(item.light),
    };
    for (const url of [pair.dark, pair.light, pathUrl(item.source)]) {
      pairs.set(url.pathname, pair);
      if (url.pathname.endsWith("/index.html"))
        pairs.set(url.pathname.slice(0, -"index.html".length), pair);
    }
  }
  const isDark = () => document.body.classList.contains("quarto-dark");
  const update = (anchor) => {
    if (!anchor || anchor.hasAttribute("download")) return;
    const xlink = "http://www.w3.org/1999/xlink";
    const htmlHref = anchor.getAttribute("href");
    const href = htmlHref ?? anchor.getAttributeNS(xlink, "href");
    if (href === null) return;
    let current;
    try {
      current = new URL(href, document.baseURI);
    } catch {
      return;
    }
    if (current.origin !== root.origin) return;
    const pair = pairs.get(current.pathname);
    if (!pair) return;
    const next = new URL(isDark() ? pair.dark : pair.light);
    next.search = current.search;
    next.hash = current.hash;
    if (href === next.href) return;
    if (htmlHref !== null) anchor.setAttribute("href", next.href);
    else anchor.setAttributeNS(xlink, "xlink:href", next.href);
  };
  const updateAll = () => document.querySelectorAll("a").forEach(update);
  updateAll();
  let dark = isDark();
  new MutationObserver(() => {
    const next = isDark();
    if (next !== dark) {
      dark = next;
      updateAll();
    }
  }).observe(document.body, {
    attributes: true,
    attributeFilter: ["class"],
  });
  for (const event of [
    "pointerover",
    "focusin",
    "click",
    "auxclick",
    "contextmenu",
  ]) {
    document.addEventListener(
      event,
      (e) => update(e.target.closest?.("a")),
      true,
    );
  }
});
