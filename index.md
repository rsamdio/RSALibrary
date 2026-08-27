# Rotaract Library (RSALibrary) Agent Map & Repository Index

Welcome to the Rotaract Library repository. This file serves as the primary navigation index and architectural map for AI coding agents and human developers.

---

## 1. Project Overview

- **Product**: Rotaract Library (`library.rsamdio.org`)
- **Publisher**: Rotaract South Asia MDIO (RSAMDIO)
- **Purpose**: A public resource hub providing curated guides, templates, brand assets, meeting agendas, and tools for Rotaract leaders across South Asia.
- **Tech Stack**: Jekyll 4.4.1 (Ruby), Tailwind CSS v3 (Node.js), Lunr.js (Search), Decap CMS (`/admin`), Netlify (Hosting & CI/CD), Google Apps Script (Request Form Backend).

---

## 2. Fast Navigation & Component Routing

Use this table to locate files and authoritative modules for specific tasks:

| Concern / Area | Primary Files / Directories | Relevant Documentation / Skill |
| :--- | :--- | :--- |
| **Resource Collections** | `_resources/*.md` | [.agents/docs/content-schema.md](.agents/docs/content-schema.md)<br>[.agents/skills/manage-resources/SKILL.md](.agents/skills/manage-resources/SKILL.md) |
| **Static Assets (PDFs, Images)** | `resources/*`, `images/*` | [.agents/docs/invariants-and-rules.md](.agents/docs/invariants-and-rules.md) |
| **Styling & Design System** | `assets/css/site.tailwind.css`<br>`tailwind.config.js` | [.agents/skills/ui-styling/SKILL.md](.agents/skills/ui-styling/SKILL.md) |
| **HTML Layouts & Templates** | `_layouts/*.html`<br>`_includes/*.html` | [.agents/docs/architecture.md](.agents/docs/architecture.md)<br>[.agents/skills/ui-styling/SKILL.md](.agents/skills/ui-styling/SKILL.md) |
| **Search Engine & Indexing** | `_plugins/search_index_generator.rb`<br>`assets/js/search-init.js`<br>`_includes/search-lunr.html` | [.agents/docs/architecture.md](.agents/docs/architecture.md) |
| **CMS Administration** | `admin/config.yml`<br>`admin/index.html` | [.agents/docs/architecture.md](.agents/docs/architecture.md)<br>[.agents/docs/content-schema.md](.agents/docs/content-schema.md) |
| **Site Metadata & SEO** | `_data/site.yml`<br>`_data/tools.yml`<br>`_config.yml` | [.agents/docs/content-schema.md](.agents/docs/content-schema.md) |
| **Request Form Backend** | `request.html`<br>`code.gs` | [.agents/docs/architecture.md](.agents/docs/architecture.md) |
| **Build & Deployment Config** | `netlify.toml`<br>`Gemfile`<br>`package.json` | [.agents/docs/development-and-build.md](.agents/docs/development-and-build.md) |
| **Invariant Checking & Sync** | `scripts/agent/check_invariants.rb`<br>`scripts/agent/sync_index.rb` | [.agents/skills/verify-repository/SKILL.md](.agents/skills/verify-repository/SKILL.md)<br>[.agents/skills/maintain-agent-harness/SKILL.md](.agents/skills/maintain-agent-harness/SKILL.md) |

---

## 3. Standard Development & Verification Commands

```bash
# Setup dependencies
npm install && bundle install

# Start local development server (Tailwind compiles automatically)
bundle exec jekyll serve

# Run automated invariant & integrity checks
ruby scripts/agent/check_invariants.rb

# Synchronize index manifest & check for documentation drift
ruby scripts/agent/sync_index.rb --check

# Test full production build
bundle exec jekyll build
```

---

## 4. Key Architectural Invariants & Rules

1. **Precedence**: Active source code is the ultimate source of truth. See [.agents/rules/code-is-truth.md](.agents/rules/code-is-truth.md).
2. **Zero Em Dashes**: Never use long em dashes (Unicode U+2014) in newly generated content, comments, or documentation. See [.agents/rules/no-em-dashes.md](.agents/rules/no-em-dashes.md).
3. **Pure ASCII Asset Filenames**: All files in `resources/` must use strict ASCII alphanumeric characters (`a-z`, `0-9`, `.`, `-`, `_`).
4. **Plugin Write Targets**: Custom Jekyll plugins must write outputs to `_site/` (`site.dest`), never to the root workspace (`site.source`).
5. **Decap CMS Parity**: Content in `_resources/*.md` must conform to widget definitions in `admin/config.yml`.

---

## 5. Documentation & Skills Catalog

### Domain Documentation (`.agents/docs/`)
- [Architecture Overview](.agents/docs/architecture.md): Lifecycle, plugins, CMS, search, Netlify flow.
- [Content Schema](.agents/docs/content-schema.md): YAML models, card structures, icons, color tokens.
- [Development & Build](.agents/docs/development-and-build.md): Commands, environments, troubleshooting.
- [Invariants & Rules](.agents/docs/invariants-and-rules.md): Non-negotiable repository guardrails.

### Agent Skills (`.agents/skills/`)
- [manage-resources](.agents/skills/manage-resources/SKILL.md): Adding and editing resource groups and cards.
- [verify-repository](.agents/skills/verify-repository/SKILL.md): Running automated verification and build checks.
- [maintain-agent-harness](.agents/skills/maintain-agent-harness/SKILL.md): Preventing documentation drift and keeping index synchronized.
- [ui-styling](.agents/skills/ui-styling/SKILL.md): Frontend modifications with Tailwind CSS and Liquid.

---

<!-- MANIFEST:START -->
### Machine-Verifiable Repository Manifest

| Metric | Count | Details / Path |
| :--- | :--- | :--- |
| **Resource Groups** | 7 | `_resources/*.md` |
| **Resource Cards** | 69 | Embedded in resource groups |
| **Static Assets** | 222 | `resources/` (Pure ASCII filenames) |
| **Ecosystem Tools** | 8 | `_data/tools.yml` |
| **Custom Plugins** | 4 | `_plugins/` (clean_sitemap.rb, llms_txt_generator.rb, search_index_generator.rb, tailwind_build.rb) |
| **Layout Templates** | 4 | `_layouts/` (compress.html, default.html, page.html, resource_group.html) |
| **Includes** | 12 | `_includes/` |
| **Data Files** | 2 | `_data/` (site.yml, tools.yml) |

#### Active Resource Groups

| Nav Order | Title | Slug | Cards | Icon & Color |
| :--- | :--- | :--- | :--- | :--- |
| 0 | RZI Learning Materials | `rzi-learning-materials` | 5 | `menu_book` (pink) |
| 0 | Roles and Responsibilities | `roles-and-responsibilities` | 2 | `picture_as_pdf` (blue) |
| 1 | Club Essentials | `club-essentials` | 7 | `support` (red) |
| 2 | Rotaract Brand Assets | `rotaract-brand-assets` | 22 | `image` (blue) |
| 3 | Agenda for Club Meetings | `agenda-for-club-meetings` | 5 | `picture_as_pdf` (blue) |
| 140 | Rotaract South Asia MDIO identity | `rsamdio-identity` | 8 | `flag` (fuchsia) |
| 200 | Batch of 26-27 Badge | `batch-of-26-27-badge` | 20 | `badge` (violet) |
<!-- MANIFEST:END -->
