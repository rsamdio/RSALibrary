---
name: verify-repository
description: Step-by-step instructions for running integrity tests, schema validation, link verification, and build testing.
---

# Skill: Verify Repository

This skill defines the complete verification protocol to ensure repository integrity, schema validity, and build stability.

## When to Use
- Before opening a pull request or committing changes.
- After adding or modifying resources, layouts, or plugins.
- When troubleshooting build or runtime errors.

## Verification Checklist

### 1. Invariant & Schema Validation
Run the automated invariant checker:
```bash
ruby scripts/agent/check_invariants.rb
```
Verify that the output reports:
- [PASS] Zero long em dashes in harness and documentation.
- [PASS] All files in `resources/` have clean ASCII filenames.
- [PASS] All resource groups and cards adhere to required schema fields.
- [PASS] All local asset paths (`preview_image_url`, `view_url`, `download_url`) exist on disk.
- [PASS] `_data/site.yml` and `_data/tools.yml` are valid.
- [PASS] All documentation links resolve to existing files.

### 2. Documentation Freshness Check
Check that `index.md` manifest matches actual repository counts:
```bash
ruby scripts/agent/sync_index.rb --check
```
If drift is detected, run:
```bash
ruby scripts/agent/sync_index.rb
```

### 3. Full Production Build
Run a clean Jekyll production build:
```bash
bundle exec jekyll build
```
Verify that:
- Tailwind CSS compiles without errors (`Done in ... ms`).
- Search index generator writes all entries to `_site/assets/js/search-index.json`.
- `_site/llms.txt` is generated.
- Exit code is 0.

### 4. Git Status & Staging Check
Review modified files before committing:
```bash
git status
```
Ensure no scratch files or temporary build artifacts were inadvertently created outside `_site/` or `.jekyll-cache/`.
