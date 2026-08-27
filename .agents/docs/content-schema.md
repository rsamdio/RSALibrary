# Content Schema & Data Models

This document defines the schema requirements, field validations, and allowed values for all content collections and metadata files in the repository.

## 1. Resource Groups (`_resources/*.md`)

Resource groups represent thematic collections of guides, documents, and media assets. Each file is a Markdown document with YAML front matter.

### Root Group Fields

| Field | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `title` | String | Yes | Display title of the resource group | `"Club Essentials"` |
| `icon` | String | Yes | Material Symbols icon identifier | `"support"`, `"diversity_3"` |
| `icon_color` | String | Yes | Color token from the allowed palette | `"blue"`, `"emerald"`, `"amber"` |
| `summary` | String | Yes | Concise description for cards and SEO | `"Induction and governance references..."` |
| `nav_order` | Integer | Yes | Sort weight for homepage and admin views | `1`, `2`, `10` |
| `placeholder` | String | No | Custom text shown when no resources exist | `"Coming soon..."` |
| `subgroups` | Array | No | Optional nested subgroups (see below) | List of subgroup objects |
| `resources` | Array | Yes | List of direct resource cards | List of resource card objects |

### Subgroup Object Fields

When a resource group contains distinct subsections, define them in the `subgroups` list:

| Field | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `title` | String | Yes | Title of the subgroup | `"Ceremonies and Protocols"` |
| `summary` | String | Yes | Description of subgroup contents | `"Key references used during inductions..."` |
| `resources` | Array | Yes | List of resource cards in this subgroup | List of resource card objects |

### Resource Card Object Fields

Every card inside `resources` or `subgroups[].resources` must contain:

| Field | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `name` | String | Yes | Display title of the resource card | `"Rotaract Oath of Induction"` |
| `description` | String | Yes | Concise explanation of the resource | `"Ready reference for the presiding officer..."` |
| `type` | String | Yes | File type or format label | `"PDF"`, `"DOCX"`, `"PNG"`, `"ZIP"`, `"Toolkit"` |
| `type_icon` | String | Yes | Material Symbols icon for the file type | `"picture_as_pdf"`, `"article"`, `"image"` |
| `preview_image_url` | String | No | Path or URL for card preview image | `"/resources/oath-preview.jpg"` |
| `view_url` | String | Yes | Primary URL opened by the View button | `"/resources/oath-of-induction.pdf"` |
| `download_url` | String | No | Optional direct download URL | `"/resources/oath-of-induction.pdf"` |

---

## 2. Allowed Palette Tokens (`icon_color`)

The following Tailwind color tokens are supported across UI themes and CMS controls:

`blue`, `sky`, `cyan`, `teal`, `emerald`, `green`, `lime`, `amber`, `yellow`, `orange`, `rose`, `pink`, `red`, `fuchsia`, `purple`, `violet`, `indigo`, `slate`

---

## 3. Site Metadata Schema (`_data/site.yml`)

`_data/site.yml` is the single source of truth for organization identity, SEO, OpenGraph tags, and LLM discovery.

```yaml
product_name: "Rotaract Library"
product_url: "https://library.rsamdio.org"
product_description: "A curated library of assets, templates, guides, checklists, and tools for Rotaract leaders."
publisher_name: "Rotaract South Asia MDIO"
publisher_short: "RSAMDIO"
publisher_url: "https://rsamdio.org/"
publisher_description: "Rotaract South Asia Multi District Information Organization (RSAMDIO) curates regional tools and resources for Rotaract leaders across South Asia."
publisher_email: "rsamdio@gmail.com"
twitter_handle: "@rsa_mdio"
logo_path: "/images/rsamdio.webp"
og_image_path: "/images/ogimage.webp"
same_as:
  - "https://rsamdio.org/"
  - "https://www.linkedin.com/company/rsamdio/"
  - "https://x.com/rsa_mdio"
  - "https://go.rsamdio.org/socials"
parent_organization:
  name: "Rotary International"
  url: "https://www.rotary.org/"
  wikidata_id: "Q1760106"
related_program:
  name: "Rotaract"
  wikidata_id: "Q2165432"
ai_bots_policy: "allow"
```

---

## 4. Ecosystem Tools Schema (`_data/tools.yml`)

`_data/tools.yml` defines the list of related RSAMDIO digital products displayed in the homepage tools grid and LLM crawler index.

Each item in the array requires:
- `name`: Tool display name (e.g., `"Club Invoice Calculator"`)
- `description`: One-line benefit statement (e.g., `"Estimate your Club Invoices with precision and ease."`)
- `icon`: Material Symbols icon name (e.g., `"receipt_long"`)
- `accent_color`: Color token matching the palette (e.g., `"blue"`)
- `url`: External HTTPS link to the tool (e.g., `"https://dues.rsamdio.org/"`)
