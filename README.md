[![Netlify Status](https://api.netlify.com/api/v1/badges/3cc42b96-b587-425b-87fd-f24908053820/deploy-status)](https://app.netlify.com/projects/rsalibrary/deploys)

## RSA Library

RSA Library is a public resource center for **Rotaract South Asia MDIO**, providing curated templates, checklists, and toolkits for Rotaract projects across South Asia.

Production site: `https://library.rsamdio.org/`

---

## Tech stack

- **Static site generator**: Jekyll 4
- **Styling**: Tailwind CSS (via CDN; no build step)
- **Search**: Client‑side Lunr.js
- **CMS**: Decap CMS (Netlify CMS successor) at `/admin`
  - Git Gateway + Netlify Identity
  - All content is stored as Markdown in the repo
- **Hosting**: Netlify
- **Request form backend**: Google Apps Script + Google Sheets

---

## Content model

### Resource groups

- Stored in `_resources/*.md`
- Front‑matter fields:
  - `title`: Group title
  - `icon`: Material Symbols icon name (e.g. `group_add`)
  - `icon_color`: Tailwind color token (e.g. `emerald`, `amber`)
  - `summary`: Short description shown on cards and hero
  - `placeholder`: Empty‑state text when a group has no resources
  - `resources`: List of resource cards (see below)

### Resource cards (per group)

Each `resources` item in a group has:

- `name`: Display name of the resource
- `description`: Short description
- `type`: Free‑text file type label (e.g. `PPTX`, `PDF`, `Toolkit`)
- `type_icon`: Material Symbols icon name for the type
- `preview_image_url`: Optional preview image (local `/resources/...` or full URL)
- `view_url`: URL the “View” button opens (local or external)
- `download_url`: Optional URL for a direct download button

Cards are rendered:

- On the homepage (`_includes/thematic-groups.html`)
- On each group page (`_layouts/resource_group.html`)
- In Lunr search results (`_includes/search-lunr.html`)

---

## Admin / editing (Decap CMS)

- CMS entry point: `/admin/index.html`
- Main collection: **Resource Groups** (`admin/config.yml`)
- Editors can:
  - Create/edit resource groups and their cards
  - Choose icons from the full **Material Symbols Outlined** set (with visual previews)
  - Choose icon colors from a curated Tailwind palette (with color swatches)
  - Use quick‑pick file type labels plus a free‑text override

All changes are committed back to this Git repository as Markdown and config updates.

---

## Request form & backend

- Frontend page: `request.html` (`/request/`)
  - Simple HTML form posting via `fetch` to a Google Apps Script endpoint
  - Endpoint URL is configured in `_config.yml` as `request_form_endpoint`
- Backend script: `code.gs`
  - `doPost(e)` appends each submission to a Google Sheet (`Requests` tab)
  - Captured fields: name, email, club, district, resource group, details, reference link
  - Sends a confirmation email to the submitter, with a CC to the manager email (`rotaract3191drr@gmail.com` by default)

If you fork this repo, you should:

1. Create your own Google Sheet and Apps Script project.
2. Copy and adapt `code.gs` (especially the spreadsheet ID and manager email).
3. Publish the script as a web app and paste the URL into `_config.yml` as `request_form_endpoint`.

---

## Local development

Prerequisites:

- Ruby and Bundler installed

Setup and run:

```bash
bundle install
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000/`.

Note: The `/admin` CMS page will load locally, but authentication and Git Gateway depend on your Netlify configuration.

---

## Deployment

- The site is deployed via **Netlify**, building from this repository.
- Standard Jekyll build command is used (`jekyll build`) with the output in `_site/`.
- The Netlify status badge at the top of this README reflects the current deploy status for the production site.

