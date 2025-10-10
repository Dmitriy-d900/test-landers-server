(function() {
    const formSubmit = () => {
        const forms = document.querySelectorAll('form');
        if (!forms || !forms.length) {
            return;
        }

        const modal = document.getElementById('thk-modal');
        const modalClose = document.getElementById('thk-modal-close');
        const modalMsg = document.querySelector('.thk-modal__text');

        const showModal = (message) => {
            modalMsg.innerHTML = message;
            modal.style.display = 'flex';
            setTimeout(() => {
                modal.classList.add('show');
            }, 4);

            setTimeout(() => {
                modal.classList.add('ready');
            }, 1500);
        };

        const hideModal = () => {
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none';
                modal.classList.remove('ready');
            }, 300);
        };

        modalClose.addEventListener('click', hideModal);

        forms.forEach((form) => {
            let correctAnswer;

            // Поиск капчи внутри формы
            const captchaInput = form.querySelector('#captcha');
            if (captchaInput) {
                // Генерация примера для капчи, если элемент captcha существует
                let num1 = Math.floor(Math.random() * 10) + 1;
                let num2 = Math.floor(Math.random() * 10) + 1;
                let operator = Math.random() > 0.5 ? '+' : '-';
                correctAnswer = operator === '+' ? num1 + num2 : num1 - num2;

                // Отображение примера в placeholder инпута капчи
                captchaInput.placeholder = `Enter the result: ${num1} ${operator} ${num2}`;
            }

            const onSubmit = (event) => {
                event.preventDefault();
                let isValid = true;
                let msg = '';

                // Проверка всех обязательных полей формы
                for (let i = 0; i < event.target.elements.length; i++) {
                    const element = event.target.elements[i];
                    if (element.type === 'hidden' || element.type === 'submit') {
                        continue;
                    }

                    if (!element.value.trim()) {
                        isValid = false;
                    }
                }

                // Проверка капчи, если элемент captcha существует в текущей форме
                if (captchaInput) {
                    if (parseInt(captchaInput.value) !== correctAnswer) {
                        isValid = false;
                        msg = 'Invalid captcha result. Try again.';
                    }
                }

                // Если все поля заполнены и капча пройдена (если она есть)
                if (isValid) {
                    msg = "Thank you for filling out the form. We will contact you soon.";
                } else if (!msg) { // Если есть незаполненные поля, но не капча
                    msg = 'Please fill out the form.';
                }

                // Отображение сообщения
                showModal(msg);

                if (isValid) {
                    // Очистка формы после успешной валидации
                    for (let i = 0; i < event.target.elements.length; i++) {
                        event.target.elements[i].value = '';
                    }
                }
            };

            form.addEventListener('submit', onSubmit);
        });
    };

    const onLoad = () => {
        const styleEl = document.createElement('style');
        const helpDiv = document.createElement('div');
        styleEl.innerHTML = '.thk-modal.ready .thk-modal__container,.thk-modal.show{opacity:1}.thk-modal{display:none;position:fixed;top:0;bottom:0;left:0;right:0;z-index:1000;background-color:rgba(0,0,0,.4);justify-content:center;align-items:center;opacity:0;transition:opacity .3s linear}@keyframes spinLoader{0%{transform:translate(-50%,-50%) rotate(45deg)}100%{transform:translate(-50%,-50%) rotate(765deg)}}.thk-modal__loader{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%) rotate(45deg);width:50px;height:50px;border-radius:50%;border-style:solid;border-width:4px;border-color:#fff transparent;animation:1.5s ease-in-out infinite spinLoader;transition:opacity .15s linear}.thk-modal__container{opacity:0;margin:0 auto;max-width:450px;position:relative;padding:25px 15px;background-color:#fff;border-radius:10px;transition:opacity .3s linear}.thk-modal.ready .thk-modal__loader{opacity:0}.thk-modal__close{position:absolute;top:-15px;right:5px;width:max-content;cursor:pointer;font-size:25px;font-weight:700}.cookies__close,.thk-modal__text{font-size:20px;color:#000;visibility:visible}.thk-modal__text{margin:0;line-height:1.4;font-weight:400;text-align:center}.cookies{position:fixed;bottom:0;left:0;right:0;width:100%;padding:20px;background-color:#fff;border-top:1px solid #9d9d9d;transition:transform .3s linear}.cookies.hide{transform:translateY(100%)}.cookies__wrapper{width:100%;padding:0 20px}.cookies__close{display:block;position:absolute;top:10px;right:10px;font-weight:700}.cookies__text{color:#000;visibility:visible}';
        helpDiv.innerHTML = `<div id="thk-modal" class="thk-modal"><div class="thk-modal__wrapper"><div class="thk-modal__loader"></div><div class="thk-modal__container"><div class="thk-modal__container"><div id="thk-modal-close" class="thk-modal__close">x</div><p class="thk-modal__text"></p></div></div></div></div>`;

        document.body.append(styleEl);
        document.body.append(helpDiv);

        formSubmit();
    };

    window.addEventListener('DOMContentLoaded', onLoad);
}());
