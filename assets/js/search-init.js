(function () {
  var indexUrl = window.__SEARCH_INDEX_URL__;
  if (!indexUrl) {
    return;
  }

  var documents = [];
  var idx = null;
  var loadPromise = null;
  var ready = false;

  function escapeAttr(s) {
    return String(s).replace(/"/g, "");
  }

  function buildIndex(docs) {
    if (typeof lunr === "undefined") {
      return;
    }
    documents = docs;
    idx = lunr(function () {
      this.ref("id");
      this.field("title");
      this.field("body");
      documents.forEach(function (doc) {
        this.add(doc);
      }, this);
    });
    ready = true;
  }

  function ensureLoaded() {
    if (ready) {
      return Promise.resolve();
    }
    if (loadPromise) {
      return loadPromise;
    }
    loadPromise = fetch(indexUrl)
      .then(function (r) {
        if (!r.ok) {
          throw new Error("search index fetch failed");
        }
        return r.json();
      })
      .then(function (docs) {
        buildIndex(docs);
      })
      .catch(function () {
        documents = [];
        ready = true;
      });
    return loadPromise;
  }

  document.addEventListener("DOMContentLoaded", function () {
    var input = document.getElementById("lunrsearch");
    if (input) {
      input.addEventListener(
        "focus",
        function () {
          ensureLoaded();
        },
        { once: true }
      );
    }
  });

  function renderResults(term, resultsContainer) {
    if (!idx) {
      var err = document.createElement("p");
      err.className = "text-xs text-amber-600 dark:text-amber-400";
      err.textContent = "Search is unavailable right now. Try again in a moment.";
      resultsContainer.appendChild(err);
      return;
    }

    var heading = document.createElement("p");
    heading.className = "text-xs md:text-sm text-slate-500 dark:text-slate-400 mb-3";
    heading.textContent = "Search results for '" + term + "'";
    resultsContainer.appendChild(heading);

    var list = document.createElement("ul");
    list.className = "space-y-3";
    resultsContainer.appendChild(list);

    var results = idx.search(term);

    if (!results.length) {
      var empty = document.createElement("li");
      empty.className = "text-sm text-slate-500 dark:text-slate-400";
      empty.textContent = "No results found...";
      list.appendChild(empty);
      return;
    }

    results.forEach(function (result) {
      var doc = documents[result.ref];
      if (!doc) {
        return;
      }

      var li = document.createElement("li");
      var bodyPreview = (doc.body || "").substring(0, 140) + "...";

      if (doc.type === "resource") {
        var viewUrl = doc.view_url || doc.url;
        var downloadUrl = doc.download_url;
        var downloadAttr = "";
        if (downloadUrl && doc.download_suggested_name) {
          downloadAttr = ' download="' + escapeAttr(doc.download_suggested_name) + '"';
        }

        li.innerHTML =
          '<div class="flex gap-4 p-4 rounded-2xl bg-white dark:bg-surface-dark border border-slate-100 dark:border-slate-700 shadow-soft hover:shadow-hover transition-shadow">' +
          (doc.preview_image_url
            ? '<div class="hidden sm:block w-20 h-20 rounded-xl overflow-hidden bg-slate-100 dark:bg-slate-800 flex-shrink-0">' +
              '<img src="' +
              doc.preview_image_url +
              '" alt="" class="w-full h-full object-cover" />' +
              "</div>"
            : "") +
          '<div class="flex-1 min-w-0">' +
          '<div class="text-xs uppercase tracking-wide text-primary mb-1">Resource</div>' +
          '<div class="text-sm font-semibold text-slate-900 dark:text-white truncate">' +
          doc.title +
          "</div>" +
          (doc.group_title
            ? '<div class="text-xs text-slate-500 dark:text-slate-400 mb-1">in ' +
              '<a href="' +
              (doc.group_url || "#") +
              '" class="underline-offset-2 hover:underline">' +
              doc.group_title +
              "</a>" +
              (doc.subgroup_title ? " / " + doc.subgroup_title : "") +
              "</div>"
            : "") +
          '<div class="text-xs text-slate-500 dark:text-slate-400 leading-relaxed mb-2 line-clamp-2">' +
          bodyPreview +
          "</div>" +
          '<div class="flex flex-wrap gap-2">' +
          (viewUrl
            ? '<a href="' +
              viewUrl +
              '" target="_blank" rel="noopener noreferrer" class="inline-flex items-center px-3 py-1.5 rounded-full text-xs font-medium bg-primary text-white hover:bg-primary-dark transition-colors">' +
              '<span class="material-symbols-outlined text-sm mr-1">open_in_new</span>View' +
              "</a>"
            : "") +
          (downloadUrl
            ? '<a href="' +
              downloadUrl +
              '"' +
              downloadAttr +
              ' rel="noopener noreferrer" class="inline-flex items-center px-3 py-1.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200 hover:bg-slate-200 dark:hover:bg-slate-700 transition-colors">' +
              '<span class="material-symbols-outlined text-sm mr-1">download</span>Download' +
              "</a>"
            : "") +
          "</div>" +
          "</div>" +
          "</div>";
      } else if (doc.type === "group") {
        li.innerHTML =
          '<a href="' +
          doc.url +
          '" class="block p-4 rounded-2xl bg-white dark:bg-surface-dark border border-slate-100 dark:border-slate-700 shadow-soft hover:shadow-hover transition-shadow">' +
          '<div class="flex items-center justify-between mb-1">' +
          '<div class="text-sm font-semibold text-slate-900 dark:text-white">' +
          doc.title +
          "</div>" +
          '<span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-rose-100 text-rose-900 dark:bg-rose-950/50 dark:text-rose-100">' +
          '<span class="material-symbols-outlined text-xs mr-1">folder</span>Resource Group' +
          "</span>" +
          "</div>" +
          '<div class="text-xs text-slate-500 dark:text-slate-400 leading-relaxed">' +
          bodyPreview +
          "</div>" +
          "</a>";
      } else {
        li.innerHTML =
          '<a href="' +
          doc.url +
          '" class="block p-4 rounded-2xl bg-white dark:bg-surface-dark border border-slate-100 dark:border-slate-700 shadow-soft hover:shadow-hover transition-shadow">' +
          '<div class="text-sm font-semibold text-slate-900 dark:text-white mb-1">' +
          doc.title +
          "</div>" +
          '<div class="text-xs text-slate-500 dark:text-slate-400 leading-relaxed">' +
          bodyPreview +
          "</div>" +
          "</a>";
      }

      list.appendChild(li);
    });
  }

  window.lunr_search = function (term) {
    var resultsContainer = document.getElementById("lunrsearchresults");
    if (!resultsContainer) {
      return false;
    }

    term = (term || "").trim();
    resultsContainer.innerHTML = "";

    if (!term) {
      return false;
    }

    ensureLoaded().then(function () {
      renderResults(term, resultsContainer);
    });

    return false;
  };
})();
