---
name: ui-styling
description: Guidelines for editing Tailwind CSS styles, Jekyll layouts, Liquid includes, responsive design, and dark mode.
---

# Skill: UI & Styling

This skill guides agents in modifying styling, layout components, and visual themes in Rotaract Library.

## When to Use
- Modifying UI components or page layouts (`_layouts/`, `_includes/`).
- Adding new Tailwind utility classes or custom colors.
- Adjusting dark mode styles or responsive breakpoints.
- Updating web fonts or Material Symbols icons.

## Guidelines & Best Practices

### 1. Tailwind CSS Workflow
- **Source File**: `assets/css/site.tailwind.css`.
- **Configuration**: `tailwind.config.js`.
- **Compiled Output**: `assets/css/site.css` (auto-built on `jekyll serve` or manually via `npm run build:css`).
- Never edit `assets/css/site.css` directly as it is overwritten during builds.

### 2. Design Tokens & Fonts
- **Primary Typography**: Plus Jakarta Sans (`font-display`).
- **Icons**: Material Symbols Outlined (`<span class="material-symbols-outlined">icon_name</span>`).
- **Brand Colors**:
  - Primary: `#17458F` (Rotary Royal Blue)
  - Secondary / Accent: `#D41B69` (Cranberry / Pink)
  - Gold / Amber: `#F7A81B`
- **Backgrounds**:
  - Light mode: `bg-background-light` (`#F8FAFC`)
  - Dark mode: `bg-background-dark` (`#0F172A`)
  - Dark surface: `bg-surface-dark` (`#1E293B`)

### 3. Component Architecture
- Place reusable UI blocks in `_includes/` (e.g. `resource-card.html`, `hero.html`, `similar-tools.html`).
- Use Liquid parameters for reusability: `{% include resource-card.html card=resource %}`.
- When creating layout templates, inherit from `default.html` or `compress.html`.

### 4. Verification
After making styling changes:
1. Recompile and verify CSS:
   ```bash
   npm run build:css
   ```
2. Test layout rendering:
   ```bash
   bundle exec jekyll build
   ```
