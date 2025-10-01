document.addEventListener("DOMContentLoaded", function () {
  const termsBtn = document.getElementById("terms-btn");
  const privacyBtn = document.getElementById("privacy-btn");

  const termsModal = document.getElementById("terms");
  const privacyModal = document.getElementById("privacy");
  const disclaimerModal = document.getElementById("disclaimer");

  function openModal(modal) {
    if (modal) modal.classList.add("model-open");
    document.body.style.overflow = "hidden";
  }

  function closeModal(modal) {
    if (modal) modal.classList.remove("model-open");
    document.body.style.overflow = "";
  }

  termsBtn?.addEventListener("click", () => openModal(termsModal));
  privacyBtn?.addEventListener("click", () => openModal(privacyModal));

  document.querySelectorAll(".custom-model-main .close-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      const modal = btn.closest(".custom-model-main");
      closeModal(modal);
    });
  });

  document
    .querySelectorAll(".custom-model-main .bg-overlay")
    .forEach((overlay) => {
      overlay.addEventListener("click", () => {
        const modal = overlay.closest(".custom-model-main");
        closeModal(modal);
      });
    });

  function createScrollDispatcher(targetEl) {
    function handleOnClick(event) {
      const el = event.currentTarget;

      if (el.hasAttribute("href") && el.getAttribute("href") !== "#") {
        return;
      }

      const closestLink = el.closest("a[href]");
      if (closestLink && closestLink.getAttribute("href") !== "#") {
        return;
      }

      event.preventDefault();

      if (targetEl) {
        targetEl.scrollIntoView({ behavior: "smooth" });
      } else {
        window.scrollTo({ top: 0, behavior: "smooth" });
      }
    }

    return function (els) {
      Array.prototype.forEach.call(els, function (el) {
        el.addEventListener("click", handleOnClick);
      });
    };
  }

  const formEl = document.querySelector("#form");
  const dispatch = createScrollDispatcher(formEl);

  dispatch(
    document.querySelectorAll("img, svg, .fa, .fab, .fas, button, .clickable")
  );
});
