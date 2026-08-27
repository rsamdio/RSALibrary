---
name: maintain-agent-harness
description: Dedicated workflow for maintaining the agent harness, detecting documentation drift, synchronizing index.md, and preventing stale instructions.
---

# Skill: Maintain Agent Harness

This skill defines the routine maintenance and audit protocol for keeping the agent operating system synchronized with the codebase.

## When to Use
- After major architectural changes, additions of new plugins, or layout overhauls.
- When resource counts or group structures change.
- When new repository rules, invariants, or tools are introduced.
- During periodic repository health audits.

## Step-by-Step Maintenance Workflow

### Step 1: Detect Architectural Changes & Drift
1. Inspect `git diff` or recently modified files to understand changes to:
   - Jekyll configuration (`_config.yml`)
   - Plugins (`_plugins/*.rb`)
   - Decap CMS configuration (`admin/config.yml`)
   - Data files (`_data/*.yml`)
   - Netlify routing (`netlify.toml`)
2. Run the drift detection check:
   ```bash
   ruby scripts/agent/sync_index.rb --check
   ```

### Step 2: Synchronize Repository Index (`index.md`)
1. Run the synchronization tool to regenerate the manifest block:
   ```bash
   ruby scripts/agent/sync_index.rb
   ```
2. Check if new directories or files require addition to the component map in `index.md`.

### Step 3: Audit Domain Documentation (`.agents/docs/`)
Review domain docs against source code:
- **`architecture.md`**: Update if plugin hooks, build pipeline, or search indexing logic change.
- **`content-schema.md`**: Update if front matter fields or CMS widgets change.
- **`development-and-build.md`**: Update if dependencies, Ruby versions, or build commands change.
- **`invariants-and-rules.md`**: Update if new constraints or security rules are established.

### Step 4: Verify Skills and Rules
1. Check that all skills in `.agents/skills/` are still relevant, accurate, and non-redundant.
2. Remove any obsolete or duplicated instructions.
3. Ensure all skill files have valid YAML front matter (`name`, `description`).

### Step 5: Enforce No-Em-Dash Policy
Verify that no long em dashes (`\u2014`) exist in any newly added or modified documentation, comments, or harness files:
```bash
ruby scripts/agent/check_invariants.rb
```

### Step 6: Validate Pre-commit Hooks
Ensure the pre-commit hook is operational:
```bash
bash scripts/agent/pre-commit-hook.sh
```
