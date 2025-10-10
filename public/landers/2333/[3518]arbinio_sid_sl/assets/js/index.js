document.addEventListener('DOMContentLoaded', function () {
  // Scroll to form
  if (Element.prototype.scrollIntoView) {
    scrollToElement('#form', 'a, img, svg, .nav__item, adv__column_link_red, .adv__section_news_text');
  }

  // Date
  initDates(formatYear);
});

// Scroll to element
function scrollToElement(elSelector, triggerSelector) {
  if (!elSelector || !triggerSelector || typeof elSelector !== 'string' || typeof triggerSelector !== 'string') {
    throw new Error('Error (scrollToElement): arguments are required and must be a string.');
  }

  var el = document.querySelector(elSelector);
  var triggers = document.querySelectorAll(triggerSelector);

  if (!el || !triggers || !triggers.length) {
    throw new Error('Error (scrollToElement): some DOM-elements not found.');
  }

  function onClick(event) {
    event.preventDefault();

    el.scrollIntoView({
      behavior: 'smooth',
      block: 'center'
    });
  }

  function callback(item) {
    item.addEventListener('click', onClick);
  }

  Array.prototype.forEach.call(triggers, callback);
}

// Date
function getDate(days) {
  days = typeof days !== 'undefined' ? days : 0;

  if (typeof days !== 'number') {
    throw new Error('Type error (getDate): argument must be a number.');
  }

  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
}

function initDates() {
  var cbs = Array.prototype.slice.call(arguments);

  var elements = document.querySelectorAll('[data-date]');
  var arrOfCbs = [
    function (date) {
      return date.toLocaleDateString();
    }
  ].concat(cbs);

  if (!elements || !elements.length) {
    throw new Error('initDates: elements not found');
  }

  var removeAttributes = function (el) {
    if (!el) return;

    el.removeAttribute('data-date');
    el.removeAttribute('data-date-value');
    el.removeAttribute('data-date-cb');
  };

  Array.prototype.forEach.call(elements, function (el) {
    var value = Number(el.getAttribute('data-date-value')) || 0;
    var cbNumber = Number(el.getAttribute('data-date-cb')) || 0;

    if (cbNumber < arrOfCbs.length) {
      el.innerText = arrOfCbs[cbNumber](getDate(value));
      removeAttributes(el);
      return;
    }

    el.innerText = arrOfCbs[0](getDate(value));
    removeAttributes(el);
  });
}

function formatYear(date) {
  return date.getFullYear();
}