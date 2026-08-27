# Development & Build Workflows

This document outlines environment setup, standard development commands, testing workflows, and build troubleshooting.

## 1. Prerequisites

- **Ruby**: Version `>= 3.2, < 4.1` (Netlify builds on Ruby `3.2.2`, local development supports Homebrew Ruby `4.0.x`).
- **Bundler**: Ruby gem manager (`gem install bundler`).
- **Node.js & npm**: Node `>= 18.x` for Tailwind CSS CLI compilation.

---

## 2. Installation & Setup

Run the following commands in the repository root:

```bash
# 1. Install Node dependencies (Tailwind CSS and plugins)
npm install

# 2. Install Ruby gems (Jekyll, converters, sitemap generator)
bundle install
```

---

## 3. Development Commands

### Start Local Development Server
```bash
bundle exec jekyll serve
```
- Available at `http://localhost:4000/`.
- Tailwind CSS automatically compiles on startup via `_plugins/tailwind_build.rb`.
- Live reloading updates the browser when content files change.

### Build Production Bundle
```bash
bundle exec jekyll build
```
- Output is generated in the `_site/` directory.
- Compiles minified CSS, builds client search index (`_site/assets/js/search-index.json`), and generates `_site/llms.txt`.

### Compile CSS Independently
```bash
npm run build:css
```
- Reads `assets/css/site.tailwind.css` and emits minified `assets/css/site.css`.

---

## 4. Verification & Testing Commands

### Run Automated Invariant Checks
```bash
ruby scripts/agent/check_invariants.rb
```
Validates:
1. No long em dashes (`\u2014`) in agent harness, docs, or newly added content.
2. Strict ASCII filenames in `resources/`.
3. YAML schema validity in `_resources/*.md` and `_data/*.yml`.
4. Existence of all referenced asset files and documentation links.

### Synchronize Repository Index & Check for Drift
```bash
# Update index.md manifest with latest counts:
ruby scripts/agent/sync_index.rb

# CI mode: Check for drift without modifying files (exits 1 on drift):
ruby scripts/agent/sync_index.rb --check
```

---

## 5. Troubleshooting & Gotchas

### Ruby 4.x Encoding Error on Static Files
- **Symptom**: `String#encode: "\xE2" from ASCII-8BIT to UTF-8 (Encoding::UndefinedConversionError)`.
- **Cause**: Non-ASCII or hidden Unicode characters (such as Word Joiner `\xE2\x81\xA0`) in filenames within `resources/`.
- **Fix**: Run `ruby scripts/agent/check_invariants.rb` to identify offending files and rename them to pure ASCII.

### Skipping Tailwind Compilation
- If working exclusively on Markdown or Ruby plugins without frontend changes, you can skip CSS rebuilds:
  ```bash
  SKIP_TAILWIND_BUILD=1 bundle exec jekyll serve
  ```

### Plugin Output Directory Rule
- Custom Jekyll plugins must write generated artifacts to `site.dest` (`_site/`), never to `site.source`. Writing to `site.source` causes Jekyll's file watcher to trigger an infinite reload loop during `jekyll serve`.
