(function () {
  const BTN_SIZE = 40;
  const ICON_SIZE = 24;
  const SVGS = {
    search:
      '<svg class="icon-svg" viewBox="0 0 16 16" aria-hidden="true"><path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398l3.85 3.85.708-.708-3.85-3.85zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0"/></svg>',
    cart: '<svg class="icon-svg" viewBox="0 0 16 16" aria-hidden="true"><path d="M0 1h2l.4 2H16l-1.5 6H4.1l-.3 1.2L13 11v1H3.3l-.2 1H14v1H2.7L1 3H0zM6 14.5A1.5 1.5 0 1 1 3 14.5 1.5 1.5 0 0 1 6 14.5m8 0A1.5 1.5 0 1 1 11 14.5 1.5 1.5 0 0 1 14 14.5"/></svg>',
    phone:
      '<svg class="icon-svg" viewBox="0 0 16 16" aria-hidden="true"><path d="M3.654 1.328a.678.678 0 0 1 1.015-.063l2.29 2.29c.329.329.445.819.252 1.24l-.805 1.768a.678.678 0 0 0 .157.761l2.457 2.457a.678.678 0 0 0 .761.157l1.768-.805c.421-.193.911-.077 1.24.252l2.29 2.29a.678.678 0 0 1-.063 1.015l-1.272.954c-.74.555-1.77.48-2.427-.177L5.085 8.915C4.428 8.258 4.353 7.228 4.908 6.488z"/></svg>',
    apps: '<svg class="icon-svg" viewBox="0 0 16 16" aria-hidden="true"><path d="M2 2h4v4H2zM10 2h4v4h-4zM2 10h4v4H2zM10 10h4v4h-4z"/></svg>',
    home: '<svg class="icon-svg" viewBox="0 0 16 16" aria-hidden="true"><path d="M8.354 1.146a.5.5 0 0 0-.708 0l-6 6 .708.708L2 7.207V14.5A1.5 1.5 0 0 0 3.5 16h9A1.5 1.5 0 0 0 14 14.5V7.207l.646.647.708-.708zM13 14.5a.5.5 0 0 1-.5.5H10v-4H6v4H3.5a.5.5 0 0 1-.5-.5V6.707l5-5 5 5z"/></svg>',
    menu: '<svg class="icon-svg" viewBox="0 0 16 16" aria-hidden="true"><path d="M2 12.5h12v-1H2zm0-4h12v-1H2zm0-4h12v-1H2z"/></svg>',
  };

  function walkAllRoots(root, cb) {
    cb(root);
    const all = root.querySelectorAll ? root.querySelectorAll("*") : [];
    for (const el of all) if (el.shadowRoot) walkAllRoots(el.shadowRoot, cb);
  }

  function makeSquareButton(a, size = BTN_SIZE) {
    a.style.position = "relative";
    a.style.display = "flex";
    a.style.alignItems = "center";
    a.style.justifyContent = "center";
    a.style.width = size + "px";
    a.style.height = size + "px";
    a.style.lineHeight = "0";
    a.style.padding = "0";
    a.style.margin = "0";
    a.style.boxSizing = "border-box";
  }
  function styleSVG(svg, size = ICON_SIZE) {
    svg.setAttribute("width", String(size));
    svg.setAttribute("height", String(size));
    svg.style.position = "absolute";
    svg.style.left = "50%";
    svg.style.top = "90%";
    svg.style.display = "block";
    svg.style.fill = "currentColor";
    svg.classList.add("icon-svg-patched");
  }

  function hookScroll(a) {
    if (a.__scrollerAttached) return;
    a.addEventListener(
      "click",
      (e) => {
        e.preventDefault();
        const target = document.querySelector("#form");
        if (target)
          target.scrollIntoView({ behavior: "smooth", block: "start" });
      },
      { passive: false }
    );
    a.__scrollerAttached = true;
  }

  function ensureIcon(anchor, name, opts = {}) {
    if (!anchor) return;
    const hasText = (anchor.textContent || "").trim().length > 0;
    if (hasText && !anchor.querySelector("svg.icon-svg, svg.icon-svg-patched"))
      return;

    let svg = anchor.querySelector("svg.icon-svg, svg.icon-svg-patched");
    if (!svg) {
      const wrap = document.createElement("span");
      wrap.innerHTML = SVGS[name] || SVGS.menu;
      svg = wrap.firstElementChild;
      anchor.insertBefore(svg, anchor.firstChild);
    }

    if (!opts.noStyle) {
      makeSquareButton(anchor);
      styleSVG(svg);
    }

    hookScroll(anchor);
  }

  function applyIn(root) {
    if (!root.querySelectorAll) return;
    const searchBtn = root.querySelector("#sdx-slot-search");
    if (searchBtn) ensureIcon(searchBtn.closest("a") || searchBtn, "search");
    ensureIcon(
      root.querySelector('a[aria-label="icon-shopping-trolley"]'),
      "cart"
    );
    ensureIcon(root.querySelector('a[aria-label="Hotline de vente"]'), "phone");
    ensureIcon(root.querySelector('a[aria-label="Apps"]'), "apps");
    ensureIcon(root.querySelector('a[aria-label="open the menu"]'), "menu");

    ensureIcon(root.querySelector('a[aria-label="home"]'), "home", {
      noStyle: true,
    });
  }

  function run() {
    walkAllRoots(document, applyIn);
  }
  const seen = new WeakSet();
  function observe(root) {
    if (!root || seen.has(root)) return;
    seen.add(root);
    const mo = new MutationObserver(run);
    mo.observe(root, { childList: true, subtree: true });
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => {
      run();
      walkAllRoots(document, observe);
    });
  } else {
    run();
    walkAllRoots(document, observe);
  }
  let t = 0;
  const id = setInterval(() => {
    run();
    if (++t > 12) clearInterval(id);
  }, 500);
})();

document.querySelectorAll(".accordion__toggle").forEach((toggle) => {
  toggle.addEventListener("click", (e) => {
    e.preventDefault();
    const content = toggle.nextElementSibling;
    toggle.classList.toggle("active");
    if (content.classList.contains("is-open")) {
      content.style.maxHeight = content.scrollHeight + "px";
      setTimeout(() => {
        content.style.maxHeight = "0";
        content.style.opacity = "0";
      }, 10);
      content.classList.remove("is-open");
    } else {
      content.classList.add("is-open");
      content.style.maxHeight = content.scrollHeight + "px";
      content.style.opacity = "1";
      content.addEventListener("transitionend", function handler() {
        if (content.classList.contains("is-open")) {
          content.style.maxHeight = "none";
        }
        content.removeEventListener("transitionend", handler);
      });
    }
  });
});
