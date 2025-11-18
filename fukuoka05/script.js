// Navigation links configuration
const navigationLinks = [
  { text: "TOP", href: "index.html" },
  { text: "TEAM", href: "team.html" },
  { text: "NOTICE", href: "notice.html" },
  { text: "COC", href: "coc.html" },
  {
    text: "ACCESS",
    href: "https://re-rental.com/ekihigashi/access/",
    hasIcon: true,
  },
  {
    text: "GOODS",
    href: "https://suzuri.jp/fukuokark",
    hasIcon: true,
  },
];

// Render navigation links
function renderNavigation() {
  const desktopNav = document.querySelector(".nav");
  const mobileNav = document.querySelector(".mobile-nav");

  if (desktopNav && mobileNav) {
    // Clear existing links
    desktopNav.innerHTML = "";
    mobileNav.innerHTML = "";

    // Render desktop navigation
    navigationLinks.forEach((link) => {
      const a = document.createElement("a");
      a.href = link.href;
      a.textContent = link.text;
      if (link.hasIcon) {
        const img = document.createElement("img");
        img.src = "images/common/arrow.svg";
        a.appendChild(img);
      }
      desktopNav.appendChild(a);
    });

    // Render mobile navigation
    navigationLinks.forEach((link) => {
      const a = document.createElement("a");
      a.href = link.href;
      a.className = "mobile-nav-link";
      a.textContent = link.text;
      if (link.hasIcon) {
        const img = document.createElement("img");
        img.src = "images/common/arrow.svg";
        a.appendChild(img);
      }
      mobileNav.appendChild(a);
    });
  }
}

// Setup navigation event listeners
function setupNavigationListeners() {
  // Smooth scrolling for desktop navigation links
  const navLinks = document.querySelectorAll(".nav a");

  navLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      const targetId = this.getAttribute("href");
      const targetElement = document.querySelector(targetId);

      // Only prevent default for internal anchor links (sections within same page)
      if (targetElement && targetId.startsWith("#")) {
        e.preventDefault();
        targetElement.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
      }
      // For external URLs or other HTML files, let default behavior happen
    });
  });

  // Setup mobile navigation listeners
  const mobileNavLinks = document.querySelectorAll(".mobile-nav-link");

  mobileNavLinks.forEach((link) => {
    link.addEventListener("click", function (e) {
      const targetId = this.getAttribute("href");
      const targetElement = document.querySelector(targetId);

      // Only prevent default for internal anchor links (sections within same page)
      if (targetElement && targetId.startsWith("#")) {
        e.preventDefault();
        const closeMobileMenuFunc =
          window.closeMobileMenu ||
          function () {
            const mobileMenuOverlay = document.querySelector(
              ".mobile-menu-overlay"
            );
            const hamburgerMenu = document.querySelector(".hamburger-menu");
            const body = document.body;

            if (hamburgerMenu) hamburgerMenu.classList.remove("active");
            if (mobileMenuOverlay) mobileMenuOverlay.classList.remove("active");
            body.style.overflow = "";
          };
        closeMobileMenuFunc();

        setTimeout(() => {
          targetElement.scrollIntoView({
            behavior: "smooth",
            block: "start",
          });
        }, 300);
      } else {
        // For external URLs or other HTML files, just close the menu and allow navigation
        const closeMobileMenuFunc =
          window.closeMobileMenu ||
          function () {
            const mobileMenuOverlay = document.querySelector(
              ".mobile-menu-overlay"
            );
            const hamburgerMenu = document.querySelector(".hamburger-menu");
            const body = document.body;

            if (hamburgerMenu) hamburgerMenu.classList.remove("active");
            if (mobileMenuOverlay) mobileMenuOverlay.classList.remove("active");
            body.style.overflow = "";
          };
        closeMobileMenuFunc();
      }
    });
  });
}

document.addEventListener("DOMContentLoaded", function () {
  // Render navigation from config
  renderNavigation();

  // Setup navigation event listeners
  setupNavigationListeners();

  // Hamburger Menu functionality
  const hamburgerMenu = document.querySelector(".hamburger-menu");
  const mobileMenuOverlay = document.querySelector(".mobile-menu-overlay");
  const closeMenu = document.querySelector(".close-menu");
  const mobileNavLinks = document.querySelectorAll(".mobile-nav-link");
  const body = document.body;

  function openMobileMenu() {
    hamburgerMenu.classList.add("active");
    mobileMenuOverlay.classList.add("active");
    body.style.overflow = "hidden";
  }

  function closeMobileMenu() {
    hamburgerMenu.classList.remove("active");
    mobileMenuOverlay.classList.remove("active");
    body.style.overflow = "";
  }

  // Make closeMobileMenu available globally
  window.closeMobileMenu = closeMobileMenu;

  // Check if elements exist before adding event listeners
  if (hamburgerMenu) {
    hamburgerMenu.addEventListener("click", function (e) {
      e.preventDefault();
      openMobileMenu();
    });
  }

  if (closeMenu) {
    closeMenu.addEventListener("click", function (e) {
      e.preventDefault();
      closeMobileMenu();
    });
  }

  if (mobileMenuOverlay) {
    mobileMenuOverlay.addEventListener("click", function (e) {
      if (e.target === mobileMenuOverlay) {
        closeMobileMenu();
      }
    });
  }

  // Close menu on escape key
  document.addEventListener("keydown", function (e) {
    if (
      e.key === "Escape" &&
      mobileMenuOverlay &&
      mobileMenuOverlay.classList.contains("active")
    ) {
      closeMobileMenu();
    }
  });

  // Handle window resize
  window.addEventListener("resize", function () {
    if (
      window.innerWidth > 768 &&
      mobileMenuOverlay &&
      mobileMenuOverlay.classList.contains("active")
    ) {
      closeMobileMenu();
    }
  });
});

//thema
document.addEventListener("DOMContentLoaded", () => {
  const targets = document.querySelectorAll(".question-icon");

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          setTimeout(() => {
            entry.target.classList.add("show");
          }, 300);
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.2 }
  );

  targets.forEach((target) => observer.observe(target));
});
