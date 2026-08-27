# Rule: Code is the Source of Truth

## Precedence Hierarchy
When conflicting instructions, documentation, or assumptions arise, agents must strictly follow this authority hierarchy:

1. **Active Source Code and Configuration**:
   - `_config.yml`, `_plugins/`, `package.json`, `Gemfile`, `admin/config.yml`, `netlify.toml`
2. **Executable Behavior and Test Results**:
   - Output from `bundle exec jekyll build` and `ruby scripts/agent/check_invariants.rb`
3. **Explicit Repository Invariants**:
   - Rules in `.agents/rules/`
4. **Generated Manifest Metadata**:
   - Output from `scripts/agent/sync_index.rb`
5. **Primary Repository Index**:
   - `index.md`
6. **Domain Documentation**:
   - Files in `.agents/docs/`
7. **External Readmes and Unverified Agent Assumptions**

## Core Guidelines
- Never assume documentation is accurate without verifying against the active codebase.
- When code and documentation differ, treat the code as the ground truth and update the documentation accordingly.
- Always inspect referenced files before executing destructive edits or refactors.
