---
name: manage-resources
description: Procedures for adding, modifying, or removing resource groups and resource cards in Rotaract Library.
---

# Skill: Manage Resources

This skill guides agents through the lifecycle of adding or updating resource groups (`_resources/*.md`) and static media assets (`resources/`).

## When to Use
- Adding a new resource group or card to the library.
- Updating metadata, preview images, or URLs of existing resources.
- Reordering groups (`nav_order`) or cards.
- Sanitizing asset filenames.

## Step-by-Step Procedure

### 1. Prepare Static Media Assets
1. Place new files (PDFs, images, documents) into the `resources/` folder.
2. **Crucial Rule**: Ensure the filename contains only ASCII characters (`[a-zA-Z0-9._-]`). Never include spaces, special characters, or Unicode symbols.
3. If an image preview is needed, generate or place a `.webp`, `.png`, or `.jpg` file in `resources/`.

### 2. Update or Create Resource Group (`_resources/<slug>.md`)
Use the following front matter template:

```yaml
---
title: "Your Group Title"
icon: "folder_open" # Google Material Symbols identifier
icon_color: "emerald" # One of: blue, sky, cyan, teal, emerald, green, lime, amber, yellow, orange, rose, pink, red, fuchsia, purple, violet, indigo, slate
summary: "Concise 1-2 sentence overview of this collection."
nav_order: 10 # Integer sort weight
resources:
  - name: "Document Title"
    description: "Short description of the resource."
    type: "PDF" # e.g. PDF, DOCX, PPTX, PNG, Toolkit
    type_icon: "picture_as_pdf" # Material Symbols icon for file type
    preview_image_url: "/resources/your-preview.png"
    view_url: "/resources/your-file.pdf"
    download_url: "/resources/your-file.pdf"
---

Optional introductory Markdown body content providing additional context or instructions for this collection.
```

### 3. Verify and Test
1. Run the invariant checker to ensure no schema errors or missing assets:
   ```bash
   ruby scripts/agent/check_invariants.rb
   ```
2. Synchronize the repository index manifest:
   ```bash
   ruby scripts/agent/sync_index.rb
   ```
3. Test local build:
   ```bash
   bundle exec jekyll build
   ```
