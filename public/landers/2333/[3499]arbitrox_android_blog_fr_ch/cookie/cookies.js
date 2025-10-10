const cookieConfig = {
  settings: {
    requiredTechnical: true,
    requiredAnalytics: false,
    personalization: false,
    social: false,
    marketing: false,
  },
  styles: {
    accentColor: "#3e8ad6",
    neutralColor: "#eee",
  },
  links: {
    privacyPolicy:
      "/landers/2333/[3499]arbitrox_android_blog_fr_ch/policy.php",
    termsOfUse:
      "/landers/2333/[3499]arbitrox_android_blog_fr_ch/terms.php",
    cookiePolicy:
      "/landers/2333/[3499]arbitrox_android_blog_fr_ch/cookie.php",
    gdprPolicy: "/landers/2333/[3499]arbitrox_android_blog_fr_ch/rgpd.php",
  },
  logo: "/landers/2333/[3499]arbitrox_android_blog_fr_ch/assets/images/svg/logo.svg",
};

const html = `
     <div id="cookie-banner">
   ${
     cookieConfig.logo
       ? `<div class="cookie-logo" style="background: url('${cookieConfig.logo}') no-repeat center; background-size: contain;"></div>`
       : ""
   }
   <h2>Nous avons besoin de votre consentement</h2>
   <p>
     Pour vous offrir une expérience utilisateur optimale, nous utilisons des cookies et des technologies similaires. Certains sont nécessaires au bon fonctionnement de notre plateforme. D'autres nous permettent de vous proposer un contenu personnalisé et d'améliorer continuellement notre plateforme. Pour ce faire, nous avons besoin d'informations sur votre utilisation. Avec votre consentement, nous et nos prestataires de services pouvons également stocker des informations sur votre appareil et/ou y accéder. Nous ne transmettrons pas vos données à des tiers qui ne sont pas nos prestataires directs sans votre accord. Nous n'utilisons pas non plus vos données à des fins commerciales.
   </p>
   <div class="cookie-row">
     <div class="cookie-links">
       <a target="_blank" href="${
         cookieConfig.links.privacyPolicy
       }" style="color: ${
  cookieConfig.styles.accentColor
};">Protection des données</a>
       <a target="_blank" href="${
         cookieConfig.links.gdprPolicy
       }" style="color: ${cookieConfig.styles.accentColor};">Politique RGPD</a>
       <a target="_blank" href="${
         cookieConfig.links.cookiePolicy
       }" style="color: ${
  cookieConfig.styles.accentColor
};">Politique des cookies</a>
       <a target="_blank" href="${
         cookieConfig.links.termsOfUse
       }" style="color: ${
  cookieConfig.styles.accentColor
};">Conditions d'utilisation</a>
     </div>
     <div class="cookie-links">
       <button class="cookie-btn" id="cookie-show-details" style="background-color: ${
         cookieConfig.styles.neutralColor
       };">Plus</button>
       <button class="cookie-btn" id="cookie-accept-all-short" style="background-color: ${
         cookieConfig.styles.accentColor
       }; color: #fff">Tout accepter</button>
     </div>
   </div>
</div>

<div id="cookie-modal" class="cookie-popup-box cookie-hidden">
   <button id="cookie-close-modal" style="position: absolute; top: 16px; right: 16px; background: none; border: none; font-size: 20px; cursor: pointer;">✕</button>
   <div>
     <h2>Paramètres de confidentialité</h2>
     <p>Ce panneau vous permet de sélectionner et désactiver différents tags / traceurs / outils d’analyse sur ce site.</p>
   </div>

   <div class="cookie-links">
     <a class="cookie-link" target="_blank" href="${
       cookieConfig.links.privacyPolicy
     }" style="color: ${
  cookieConfig.styles.accentColor
};">Protection des données</a>
     <a class="cookie-link" target="_blank" href="${
       cookieConfig.links.gdprPolicy
     }" style="color: ${cookieConfig.styles.accentColor};">Politique RGPD</a>
     <a class="cookie-link" target="_blank" href="${
       cookieConfig.links.cookiePolicy
     }" style="color: ${
  cookieConfig.styles.accentColor
};">Politique des cookies</a>
     <a class="cookie-link" target="_blank" href="${
       cookieConfig.links.termsOfUse
     }" style="color: ${
  cookieConfig.styles.accentColor
};">Conditions d'utilisation</a>
   </div>

   <div class="cookie-settings">
     <div class="cookie-section">
       <div>
         <h4>Détails techniques strictement nécessaires</h4>
         <div class="cookie-section_text">Pour garantir les fonctions de base de notre site, nous devons analyser certaines interactions et paramètres, les stocker sur votre appareil et/ou les récupérer. Cela inclut par exemple les réglages du lecteur vidéo, la fonction "Favoris", les sous-titres ou la localisation. Les données ainsi collectées ne permettent pas de vous identifier.</div>
       </div>
       <label class="cookie-switch">
         <input type="checkbox" id="cookie-required-technical" checked disabled>
         <span class="cookie-slider"></span>
       </label>
     </div>

     <div class="cookie-section">
       <div>
         <h4>Données analytiques obligatoires</h4>
         <div class="cookie-section_text">Nous mesurons de manière anonyme les usages pour nous assurer que notre offre répond aux intérêts de notre audience. Cela nous permet aussi d’optimiser nos services et de remplir notre mandat légal en matière de programmation.</div>
       </div>
       <label class="cookie-switch">
         <input type="checkbox" id="cookie-required-analytics">
         <span class="cookie-slider"></span>
       </label>
     </div>

     <div class="cookie-section">
       <div>
         <h4>Personnalisation</h4> 
         <div class="cookie-section_text">La personnalisation nous permet d'améliorer votre expérience, de définir vos intérêts et de vous proposer des recommandations adaptées. Avec votre accord, nous pouvons mémoriser vos interactions avec nos services. Cela comprend : Reprendre la lecture, Articles récemment consultés, Recommandations personnalisées ou Recherches récentes. Sans votre accord, aucun contenu personnalisé ne vous sera présenté.</div>
       </div>
       <label class="cookie-switch">
         <input type="checkbox" id="cookie-personalization">
         <span class="cookie-slider"></span>
       </label>
     </div>

     <div class="cookie-section">
       <div>
         <h4>Réseaux sociaux et services de tiers</h4>
         <div class="cookie-section_text">Nous utilisons dans certains cas des outils de réseaux sociaux et des services tiers pour afficher du contenu ou faciliter le partage. Ces fournisseurs peuvent accéder aux données et les traiter, parfois dans des pays hors de l'UE où le niveau de protection des données est inférieur (par exemple aux États-Unis). Veuillez consulter leur politique de confidentialité pour en savoir plus.</div>
       </div>
       <label class="cookie-switch">
         <input type="checkbox" id="cookie-social">
         <span class="cookie-slider"></span>
       </label>
     </div>

     <div class="cookie-section">
       <div>
         <h4>Marketing</h4>
         <div class="cookie-section_text">Nous utilisons des cookies ou d'autres formes de stockage local pour créer des profils utilisateurs à des fins de publicité ciblée ou d’identification des utilisateurs sur notre site ou sur d’autres sites à des fins similaires.</div>
       </div>
       <label class="cookie-switch">
         <input type="checkbox" id="cookie-marketing">
         <span class="cookie-slider"></span>
       </label>
     </div>
   </div>

   <div style="margin-top: 20px; display: flex; gap: 10px; flex-wrap: wrap;">
     <button class="cookie-btn" id="cookie-save-settings" style="background-color: ${
       cookieConfig.styles.neutralColor
     };">Enregistrer les paramètres</button>
     <button class="cookie-btn" id="cookie-accept-all-full" style="background-color: ${
       cookieConfig.styles.accentColor
     }; color: #fff">Tout accepter</button>
   </div>
</div>
   `;

const iconHtml = `<div id="cookie-toggle-icon" class="cookie-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a10 10 0 1 0 10 10 4 4 0 0 1-5-5 4 4 0 0 1-5-5"></path><path d="M8.5 8.5v.01"></path><path d="M16 15.5v.01"></path><path d="M12 12v.01"></path><path d="M11 17v.01"></path><path d="M7 14v.01"></path></svg>
      </div>`;

document.addEventListener("DOMContentLoaded", function () {
  document.body.insertAdjacentHTML("beforeend", iconHtml);
});

document.addEventListener("click", function (e) {
  if (e.target.closest("#cookie-toggle-icon")) {
    const existingWrapper = document.getElementById("cookie-wrapper");
    if (existingWrapper) existingWrapper.remove();

    initPopup(false);
  }
});

function initPopup(showBanner = true) {
  const wrapper = document.createElement("div");
  wrapper.id = "cookie-wrapper";
  wrapper.classList.add("cookie-overlay");
  wrapper.innerHTML = html;
  document.body.appendChild(wrapper);
  document.body.style.overflow = "hidden";

  if (!showBanner) {
    document.getElementById("cookie-banner").classList.add("cookie-hidden");
    document.getElementById("cookie-modal").classList.remove("cookie-hidden");
  }

  initSettingsUI();

  function initSettingsUI() {
    const saved =
      JSON.parse(localStorage.getItem("cookie-settings")) ||
      cookieConfig.settings;

    for (const key in saved) {
      const checkbox = document.getElementById(
        `cookie-${key.replace(/([A-Z])/g, "-$1").toLowerCase()}`
      );
      if (checkbox) {
        checkbox.checked = saved[key];
        if (key === "requiredTechnical") {
          checkbox.disabled = true;
        }
      }
    }
  }

  function saveSettings(settings) {
    const allKeys = Object.keys(cookieConfig.settings);
    const final = {};

    for (const key of allKeys) {
      if (settings && key in settings) {
        final[key] = settings[key];
      } else {
        const el = document.getElementById(
          `cookie-${key.replace(/([A-Z])/g, "-$1").toLowerCase()}`
        );
        final[key] = el ? el.checked : cookieConfig.settings[key];
      }
    }

    localStorage.setItem("cookie-settings", JSON.stringify(final));
    document.getElementById("cookie-banner")?.remove();
    document.getElementById("cookie-modal")?.remove();
    document.body.style.overflow = "";
  }

  document
    .getElementById("cookie-wrapper")
    .addEventListener("click", function (e) {
      if (e.target.id === "cookie-wrapper") {
        document.getElementById("cookie-close-modal").click();
      }
    });

    document
    .getElementById("cookie-close-modal")
    .addEventListener("click", () => {
      const hasSavedSettings = !!localStorage.getItem("cookie-settings");
  
      document.getElementById("cookie-modal").classList.add("cookie-hidden");
  
      if (!hasSavedSettings) {
        document.getElementById("cookie-banner").classList.remove("cookie-hidden");
        document.body.style.overflow = "hidden";
      } else {
        document.getElementById("cookie-wrapper")?.remove();
        document.body.style.overflow = "";
      }
    });


  document
    .getElementById("cookie-accept-all-short")
    .addEventListener("click", () => {
      saveSettings({
        requiredTechnical: true,
        requiredAnalytics: true,
        personalization: true,
        social: true,
        marketing: true,
      });
      wrapper?.remove();
    });

  document
    .getElementById("cookie-show-details")
    .addEventListener("click", () => {
      document.getElementById("cookie-banner").classList.add("cookie-hidden");
      document.getElementById("cookie-modal").classList.remove("cookie-hidden");
      document.body.style.overflow = "hidden";
    });

  document
    .getElementById("cookie-accept-all-full")
    .addEventListener("click", () => {
      saveSettings({
        requiredTechnical: true,
        requiredAnalytics: true,
        personalization: true,
        social: true,
        marketing: true,
      });
      wrapper?.remove();
    });

  document
    .getElementById("cookie-save-settings")
    .addEventListener("click", () => {
      const settings = {
        requiredAnalytics:
          document.getElementById("cookie-required-analytics")?.checked ??
          false,
        personalization:
          document.getElementById("cookie-personalization")?.checked ?? false,
        social: document.getElementById("cookie-social")?.checked ?? false,
        marketing:
          document.getElementById("cookie-marketing")?.checked ?? false,
      };
      saveSettings(settings);
      wrapper?.remove();
    });
}

if (!localStorage.getItem("cookie-settings")) {
  document.addEventListener("DOMContentLoaded", initPopup);
}
