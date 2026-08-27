# Architecture Overview

This document describes the architectural components, data flows, and build pipelines of the Rotaract Library repository.

## 1. High-Level Architecture

Rotaract Library (`RSALibrary`) is a static resource center deployed on Netlify at `https://library.rsamdio.org/`. It serves curated assets, templates, guides, checklists, and tools for Rotaract leaders across South Asia.

```
+-------------------------------------------------------------------------+
|                              Source Layer                               |
|  - Content: _resources/*.md                                             |
|  - Metadata: _data/site.yml, _data/tools.yml                            |
|  - Assets: resources/*, images/*, assets/fonts/*                        |
|  - Templates: _layouts/*, _includes/*, *.html                           |
+------------------------------------+------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                        Jekyll Build Lifecycle                           |
|                                                                         |
|  1. :after_reset Hook -> _plugins/tailwind_build.rb                     |
|     Executes `npm run build:css` (tailwindcss CLI -> assets/css/site.css)|
|                                                                         |
|  2. Jekyll Core Engine                                                  |
|     Parses Front Matter, Markdown, Collections, Liquid Layouts          |
|                                                                         |
|  3. Generator Phase -> _plugins/llms_txt_generator.rb                   |
|     Builds structured llms.txt content from site and tools metadata     |
|                                                                         |
|  4. :post_write Hooks:                                                  |
|     - _plugins/search_index_generator.rb -> _site/assets/js/search-index.json
|     - _plugins/llms_txt_generator.rb -> _site/llms.txt                  |
|     - _plugins/clean_sitemap.rb -> filters _site/sitemap.xml            |
+------------------------------------+------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                        Production Output (_site)                        |
|  - Static HTML pages                                                    |
|  - Compiled CSS bundle & immutable fonts                                |
|  - Client-side Lunr.js search engine & dynamic JSON index                |
|  - Decap CMS admin interface (/admin)                                   |
|  - Netlify configuration (caching headers, canonical redirects, 404)    |
+-------------------------------------------------------------------------+
```

## 2. Component Details

### Static Site Generator (Jekyll 4)
- **Configuration**: `_config.yml` defines site title, URL, collections, defaults, and HTML compression settings.
- **Collections**: The `resources` collection reads from `_resources/*.md` and outputs pages at `/:name/` using `_layouts/resource_group.html`.
- **Layout Hierarchy**:
  - `_layouts/compress.html`: Root HTML minification.
  - `_layouts/default.html`: Master wrapper providing SEO meta tags, OpenGraph, Twitter cards, Schema.org JSON-LD, font preloading, header, footer, and search modal.
  - `_layouts/resource_group.html`: Layout for individual resource collection pages.
  - `_layouts/page.html`: Layout for standalone markdown pages (about, faq, privacy, terms).

### CSS & Design System (Tailwind CSS v3)
- **Configuration**: `tailwind.config.js` defines color palettes, custom fonts (Plus Jakarta Sans, Material Symbols Outlined), container queries, and typography plugins.
- **Entry Point**: `assets/css/site.tailwind.css`.
- **Build Hook**: `_plugins/tailwind_build.rb` automatically invokes `npm run build:css` during `bundle exec jekyll build` and `bundle exec jekyll serve`, ensuring the compiled `assets/css/site.css` is always fresh.

### Search Architecture (Lunr.js)
- **Index Generator**: `_plugins/search_index_generator.rb` collects content from all static pages, resource groups, and individual resource cards during the `:post_write` hook, outputting `_site/assets/js/search-index.json`.
- **Frontend Controller**: `assets/js/search-init.js` loads the index asynchronously, performs client-side fuzzy searching with Lunr.js, and renders interactive search results inside the search modal (`_includes/search-lunr.html`).

### Content Management (Decap CMS)
- **Admin Interface**: Accessible at `/admin/index.html`.
- **Backend**: Uses Git Gateway with Netlify Identity for authentication.
- **Configuration**: `admin/config.yml` configures editorial workflows and field widgets.
- **Custom UI Widgets** (implemented in `admin/index.html`):
  - `materialIconSelect`: Searchable dropdown with visual previews of Google Material Symbols.
  - `iconColorSelect`: Curated Tailwind color picker with visual color swatches.
  - `fileTypeCombo`: File extension text input with quick-pick presets.

### Request Form & Automation Backend
- **Frontend**: `request.html` provides an accessible form for users requesting new resources or reporting missing assets.
- **Google Apps Script**: `code.gs` is deployed as a Web App endpoint (`doPost(e)`). It logs form submissions to a Google Sheet (`Requests` tab) and sends automated email confirmations to the submitter with CC to the manager email.
- **Endpoint Config**: Configured in `_config.yml` under `request_form_endpoint`.

### Hosting & Deployment (Netlify)
- **Configuration**: `netlify.toml`
- **Build Command**: `npm ci && bundle install && bundle exec jekyll build`
- **Publish Directory**: `_site`
- **Headers & Optimization**:
  - Long-term immutable caching (`max-age=31536000, immutable`) for web fonts and static libraries.
  - Revalidation caching (`max-age=86400, must-revalidate`) for CSS and scripts.
  - Canonical domain redirect forcing `rsalibrary.netlify.app` traffic to `library.rsamdio.org`.
  - Fallback routing for `404.html`.
