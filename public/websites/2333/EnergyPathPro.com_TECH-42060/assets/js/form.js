document.addEventListener("DOMContentLoaded", function () {
  const forms = document.querySelectorAll("form");

  forms.forEach((form) => {
    const submitButton = form.querySelector('button[type="submit"]');

    form.addEventListener("submit", function (e) {
      e.preventDefault();

      const originalText = submitButton.innerHTML;
      submitButton.innerHTML =
        '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';
      submitButton.disabled = true;

      const formData = new FormData(form);

      fetch(form.action, {
        method: form.method || "POST",
        body: formData,
      })
        .then(async (response) => {
          if (!response.ok) {
            throw new Error(`Ошибка ${response.status}`);
          }
          const text = await response.text();
          return text;
        })
        .then((body) => {
          form.reset();
          submitButton.innerHTML = originalText;
          submitButton.disabled = false;

          const modal = document.getElementById("formSuccessModal");
          if (modal) {
            modal.classList.add("active");
          }
        })
        .catch((err) => {
          console.error("Ошибка при отправке формы:", err);

          submitButton.innerHTML = originalText;
          submitButton.disabled = false;
          alert("При отправке произошла ошибка. Попробуйте позже.");
        });
    });
  });

  const modal = document.getElementById("formSuccessModal");
  const closeBtn = document.querySelector(".btn-close");

  if (closeBtn) {
    closeBtn.addEventListener("click", () => {
      modal.classList.remove("active");
    });
  }

  if (modal) {
    modal.addEventListener("click", function (e) {
      const box = modal.querySelector(".modal-success-box");
      if (!box.contains(e.target)) {
        modal.classList.remove("active");
      }
    });
  }
});
