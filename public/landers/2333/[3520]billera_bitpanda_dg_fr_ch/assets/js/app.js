document.addEventListener("DOMContentLoaded", () => {
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
