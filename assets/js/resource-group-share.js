(function () {
  function closeShareMenu(shareRoot) {
    var toggle = shareRoot.querySelector("[data-share-toggle]");
    var menu = shareRoot.querySelector("[data-share-menu]");
    if (!toggle || !menu) return;
    menu.classList.add("hidden");
    toggle.setAttribute("aria-expanded", "false");
    menu.setAttribute("aria-hidden", "true");
  }

  function closeAllShareMenusExcept(exceptRoot) {
    document.querySelectorAll("[data-resource-group-share-root]").forEach(function (shareRoot) {
      if (exceptRoot && shareRoot === exceptRoot) return;
      closeShareMenu(shareRoot);
    });
  }

  function bindShareRoot(shareRoot) {
    if (shareRoot.dataset.shareBound === "1") return;
    shareRoot.dataset.shareBound = "1";

    var toggle = shareRoot.querySelector("[data-share-toggle]");
    var menu = shareRoot.querySelector("[data-share-menu]");
    var deviceBtn = shareRoot.querySelector("[data-share-device]");
    var copyBtn = shareRoot.querySelector("[data-share-copy]");
    var copyLabel = shareRoot.querySelector("[data-share-copy-label]");
    if (!toggle || !menu || !deviceBtn || !copyBtn || !copyLabel) return;

    var shareUrl = shareRoot.getAttribute("data-share-url") || window.location.href;
    var shareTitle = shareRoot.getAttribute("data-share-title") || document.title;

    if (!navigator.share) {
      deviceBtn.classList.add("hidden");
    }

    toggle.addEventListener("click", function (e) {
      e.stopPropagation();
      var open = toggle.getAttribute("aria-expanded") === "true";
      if (open) {
        closeShareMenu(shareRoot);
      } else {
        closeAllShareMenusExcept(shareRoot);
        menu.classList.remove("hidden");
        toggle.setAttribute("aria-expanded", "true");
        menu.setAttribute("aria-hidden", "false");
      }
    });

    deviceBtn.addEventListener("click", function () {
      if (!navigator.share) return;
      navigator
        .share({
          title: shareTitle,
          text: shareTitle,
          url: shareUrl,
        })
        .then(function () {
          closeShareMenu(shareRoot);
        })
        .catch(function () {});
    });

    copyBtn.addEventListener("click", function () {
      function done() {
        var prev = copyLabel.textContent;
        copyLabel.textContent = "Link copied";
        window.setTimeout(function () {
          copyLabel.textContent = prev;
          closeShareMenu(shareRoot);
        }, 1600);
      }

      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(shareUrl).then(done).catch(function () {
          window.prompt("Copy this link:", shareUrl);
          closeShareMenu(shareRoot);
        });
      } else {
        window.prompt("Copy this link:", shareUrl);
        closeShareMenu(shareRoot);
      }
    });
  }

  function initResourceGroupShareRoots() {
    document.querySelectorAll("[data-resource-group-share-root]").forEach(bindShareRoot);
  }

  if (!window.__resourceGroupShareDocListeners) {
    window.__resourceGroupShareDocListeners = true;
    document.addEventListener("click", function (e) {
      document.querySelectorAll("[data-resource-group-share-root]").forEach(function (shareRoot) {
        var toggle = shareRoot.querySelector("[data-share-toggle]");
        if (!toggle || toggle.getAttribute("aria-expanded") !== "true") return;
        if (!shareRoot.contains(e.target)) {
          closeShareMenu(shareRoot);
        }
      });
    });
    document.addEventListener("keydown", function (e) {
      if (e.key !== "Escape") return;
      var focused = false;
      document.querySelectorAll("[data-resource-group-share-root]").forEach(function (shareRoot) {
        var toggle = shareRoot.querySelector("[data-share-toggle]");
        if (toggle && toggle.getAttribute("aria-expanded") === "true") {
          closeShareMenu(shareRoot);
          if (!focused) {
            toggle.focus();
            focused = true;
          }
        }
      });
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initResourceGroupShareRoots);
  } else {
    initResourceGroupShareRoots();
  }
})();
