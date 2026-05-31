document.addEventListener("DOMContentLoaded", () => {
  function formatDate(date) {
    const options = { month: "long", day: "numeric", year: "numeric" };
    let formatted = new Intl.DateTimeFormat("ja", options).format(date);
    return formatted.replace(/^(\d+)\.\s/, "$1 ");
  }

  function getDateWithOffset(offset) {
    const currentDate = new Date();
    currentDate.setDate(currentDate.getDate() + offset);
    return currentDate;
  }

  document.querySelectorAll("[data-date-offset]").forEach((element) => {
    const offset = parseInt(element.getAttribute("data-date-offset"), 10);
    const dateWithOffset = getDateWithOffset(offset);
    const formattedDate = formatDate(dateWithOffset);
    element.textContent = formattedDate;
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
