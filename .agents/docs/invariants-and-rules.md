# Repository Invariants & Guardrails

This document details the architectural boundaries, security policies, and non-negotiable rules for the Rotaract Library repository.

## 1. Zero Long Em Dashes (`\u2014`)

- **Rule**: Long em dashes (Unicode U+2014) must not be used anywhere in agent-generated content, documentation, commit messages, comments, or UI copy.
- **Replacements**: Use colons, commas, hyphens, parentheses, or separate sentences.
- **Enforcement**: Automated via `scripts/agent/check_invariants.rb` and `scripts/agent/pre-commit-hook.sh`.

---

## 2. Strict Pure ASCII Asset Filenames

- **Rule**: All filenames in `resources/` and `images/` must consist solely of standard ASCII characters: letters (`a-z`, `A-Z`), digits (`0-9`), periods (`.`), hyphens (`-`), and underscores (`_`).
- **Rationale**: Invisible Unicode characters (such as Word Joiners `\xE2\x81\xA0` or non-breaking spaces) cause Jekyll 4.x url unescaping to fail with fatal encoding errors under Ruby 4.x.
- **Enforcement**: Validated during invariant checks.

---

## 3. Single Source of Truth for Organization Identity

- **Rule**: Never hardcode organization names, contact emails, social links, or publisher descriptors into Liquid layouts or includes.
- **Location**: All identity parameters must be defined in `_data/site.yml` and accessed via `{{ site.data.site.<key> }}`.
- **Related Tools**: Ecosystem digital tools must be defined in `_data/tools.yml`.

---

## 4. Jekyll Plugin Destination Boundary

- **Rule**: Plugins operating on `:post_write` hooks (such as `_plugins/search_index_generator.rb` and `_plugins/llms_txt_generator.rb`) must write generated artifacts to `site.dest` (`_site/`), NEVER to `site.source`.
- **Rationale**: Writing into the workspace root during build causes `jekyll --watch` to detect file system changes and enter an infinite build loop.

---

## 5. Decap CMS Schema Compatibility

- **Rule**: Any structural modifications to files in `_resources/*.md` must maintain bidirectional compatibility with Decap CMS configuration in `admin/config.yml`.
- **Widgets**: Cards must support all standard fields (`name`, `description`, `type`, `type_icon`, `preview_image_url`, `view_url`, `download_url`).
- **Icons**: Icon values must correspond to valid Google Material Symbols Outlined tokens.
- **Colors**: Group `icon_color` values must belong to the curated Tailwind color set.

---

## 6. Sitemap Purity

- **Rule**: The generated `sitemap.xml` must exclude administrative paths (`/admin/`) and direct binary asset files (`.pdf`, `.png`, `.jpg`, `.zip`, `.docx`).
- **Mechanism**: Enforced automatically by `_plugins/clean_sitemap.rb` on the `:post_write` hook.

---

## 7. SEO & Structured Data

- **Rule**: Every public page must have a unique title, meta description, canonical URL, OpenGraph metadata, Twitter card, and appropriate Schema.org JSON-LD tags.
- **Implementation**: Provided automatically by `_layouts/default.html` using page front matter falling back to site defaults.
