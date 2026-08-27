#!/usr/bin/env bash
# Git pre-commit hook for Rotaract Library Agent Harness
# Enforces:
# 1. Invariant checks (no em dashes, pure ASCII filenames, valid YAML, valid links)
# 2. Synchronized index.md manifest (no documentation drift)

set -e

echo "==> Running Rotaract Library pre-commit checks..."

# Check 1: Invariants
ruby scripts/agent/check_invariants.rb

# Check 2: Index Manifest Synchronization
ruby scripts/agent/sync_index.rb --check

echo "==> All pre-commit checks passed!"
exit 0
