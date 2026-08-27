#!/usr/bin/env ruby
# frozen_string_literal: true

# Verification script for Rotaract Library Agent Invariants
# Validates:
# 1. No long em dashes in agent harness, rules, skills, and documentation
# 2. Pure ASCII filenames in resources/
# 3. YAML front matter validity and schema compliance in _resources/ and _data/
# 4. Internal file reference existence (preview_image_url, view_url, download_url)
# 5. Link integrity across index.md and .agents/docs/

require "yaml"
require "pathname"
require "set"

ROOT = Pathname.new(__dir__).join("../..").expand_path
ERRORS = []
WARNINGS = []

def error(msg)
  ERRORS << msg
  puts " [ERROR] #{msg}"
end

def warn_msg(msg)
  WARNINGS << msg
  puts " [WARN]  #{msg}"
end

def info(msg)
  puts " [INFO]  #{msg}"
end

def pass(msg)
  puts " [PASS]  #{msg}"
end

puts "=" * 70
puts "Running Rotaract Library Invariant Checks"
puts "=" * 70

# -----------------------------------------------------------------------------
# Check 1: Enforce No Long Em Dashes in Agent Harness & Documentation
# -----------------------------------------------------------------------------
info "Checking for long em dash (\\u2014) violations in agent harness & docs..."

harness_patterns = [
  "AGENTS.md",
  "index.md",
  ".agents/**/*.md",
  "scripts/agent/**/*.rb",
  "scripts/agent/**/*.sh"
]

harness_files = harness_patterns.flat_map { |p| Dir.glob(ROOT.join(p).to_s) }.uniq

em_dash_violations = 0
harness_files.each do |file_path|
  next unless File.file?(file_path)

  rel = Pathname.new(file_path).relative_path_from(ROOT).to_s
  File.readlines(file_path, encoding: "utf-8").each_with_index do |line, idx|
    if line.include?("\u2014")
      error("#{rel}:#{idx + 1} contains long em dash character (\\u2014). Replace with hyphen, colon, or parentheses.")
      em_dash_violations += 1
    end
  end
end

if em_dash_violations.zero?
  pass "Zero long em dashes found in agent harness files (#{harness_files.size} files checked)."
end

# -----------------------------------------------------------------------------
# Check 2: Pure ASCII Filenames in resources/
# -----------------------------------------------------------------------------
info "Checking resources/ for non-ASCII or invisible Unicode characters..."

resource_files = Dir.glob(ROOT.join("resources", "*")).select { |f| File.file?(f) }
non_ascii_files = resource_files.reject { |f| File.basename(f).ascii_only? }

if non_ascii_files.any?
  non_ascii_files.each do |f|
    error("Non-ASCII character detected in asset filename: #{File.basename(f)}")
  end
else
  pass "All #{resource_files.size} files in resources/ have clean ASCII filenames."
end

# -----------------------------------------------------------------------------
# Check 3: YAML Front Matter & Content Schema in _resources/
# -----------------------------------------------------------------------------
info "Validating _resources/*.md collections and schema..."

REQUIRED_GROUP_FIELDS = %w[title icon icon_color summary nav_order].freeze
ALLOWED_COLORS = %w[
  blue sky cyan teal emerald green lime amber yellow orange rose pink red fuchsia purple violet indigo slate
].freeze

resource_group_files = Dir.glob(ROOT.join("_resources", "*.md"))
if resource_group_files.empty?
  error("No resource group files found in _resources/")
end

all_cards = []

resource_group_files.each do |file_path|
  rel = Pathname.new(file_path).relative_path_from(ROOT).to_s
  content = File.read(file_path, encoding: "utf-8")

  unless content.start_with?("---")
    error("#{rel}: Missing front matter start delimiter (---)")
    next
  end

  parts = content.split("---", 3)
  if parts.size < 3
    error("#{rel}: Invalid front matter structure")
    next
  end

  begin
    data = YAML.safe_load(parts[1])
  rescue StandardError => e
    error("#{rel}: YAML parsing error: #{e.message}")
    next
  end

  unless data.is_a?(Hash)
    error("#{rel}: Front matter is not a valid YAML mapping")
    next
  end

  REQUIRED_GROUP_FIELDS.each do |req_field|
    if data[req_field].nil? || data[req_field].to_s.strip.empty?
      error("#{rel}: Missing required field '#{req_field}'")
    end
  end

  color = data["icon_color"].to_s.strip
  unless ALLOWED_COLORS.include?(color)
    warn_msg("#{rel}: icon_color '#{color}' is outside standard palette: #{ALLOWED_COLORS.join(', ')}")
  end

  cards = []
  (data["resources"] || []).each do |card|
    card["_source_group"] = rel
    cards << card
  end

  (data["subgroups"] || []).each do |subgroup|
    (subgroup["resources"] || []).each do |card|
      card["_source_group"] = rel
      card["_subgroup"] = subgroup["title"]
      cards << card
    end
  end

  cards.each do |card|
    card_name = card["name"].to_s.strip
    if card_name.empty?
      error("#{rel}: Card is missing 'name' field")
    end
    if card["type"].to_s.strip.empty?
      error("#{rel}: Card '#{card_name}' is missing 'type' field")
    end
    if card["type_icon"].to_s.strip.empty?
      error("#{rel}: Card '#{card_name}' is missing 'type_icon' field")
    end
    if card["view_url"].to_s.strip.empty?
      error("#{rel}: Card '#{card_name}' is missing 'view_url' field")
    end
    all_cards << card
  end
end

pass "Validated #{resource_group_files.size} resource groups and #{all_cards.size} resource cards."

# -----------------------------------------------------------------------------
# Check 4: Validate Internal Asset Paths
# -----------------------------------------------------------------------------
info "Checking local file paths in resource cards..."

missing_assets = 0
all_cards.each do |card|
  %w[preview_image_url view_url download_url].each do |field|
    url = card[field].to_s.strip
    next if url.empty? || url.include?("://") || url.start_with?("#")

    local_path = if url.start_with?("/resources/")
                   ROOT.join("resources", url.sub(%r{^/resources/}, "")).to_s
                 elsif url.start_with?("/images/")
                   ROOT.join("images", url.sub(%r{^/images/}, "")).to_s
                 else
                   ROOT.join(url.sub(%r{^/}, "")).to_s
                 end

    unless File.file?(local_path)
      error("#{card['_source_group']}: Card '#{card['name']}' references missing file '#{url}'")
      missing_assets += 1
    end
  end
end

if missing_assets.zero?
  pass "All internal asset references resolve to existing files on disk."
end

# -----------------------------------------------------------------------------
# Check 5: Validate Data Files (_data/site.yml & _data/tools.yml)
# -----------------------------------------------------------------------------
info "Validating site data files..."

site_yml_path = ROOT.join("_data", "site.yml")
if File.file?(site_yml_path)
  site_data = YAML.safe_load(File.read(site_yml_path, encoding: "utf-8"))
  %w[product_name product_url publisher_name publisher_short].each do |f|
    error("_data/site.yml missing required key '#{f}'") if site_data[f].to_s.strip.empty?
  end
  pass "_data/site.yml is valid."
else
  error("_data/site.yml is missing.")
end

tools_yml_path = ROOT.join("_data", "tools.yml")
if File.file?(tools_yml_path)
  tools_data = YAML.safe_load(File.read(tools_yml_path, encoding: "utf-8"))
  if tools_data.is_a?(Array)
    tools_data.each_with_index do |tool, idx|
      error("_data/tools.yml item ##{idx + 1} missing 'name'") if tool["name"].to_s.strip.empty?
      error("_data/tools.yml item ##{idx + 1} missing 'url'") if tool["url"].to_s.strip.empty?
    end
    pass "_data/tools.yml contains #{tools_data.size} valid tool definitions."
  else
    error("_data/tools.yml is not an array")
  end
else
  error("_data/tools.yml is missing.")
end

# -----------------------------------------------------------------------------
# Check 6: Link Integrity in index.md and .agents/docs/
# -----------------------------------------------------------------------------
info "Checking link integrity in index.md and .agents/docs/..."

doc_files = Dir.glob(ROOT.join(".agents", "**", "*.md")) + [ROOT.join("index.md").to_s, ROOT.join("AGENTS.md").to_s]
broken_links = 0

doc_files.each do |doc_file|
  next unless File.file?(doc_file)

  rel_doc = Pathname.new(doc_file).relative_path_from(ROOT).to_s
  content = File.read(doc_file, encoding: "utf-8")

  # Match markdown links: [text](path)
  content.scan(/\[([^\]]+)\]\(([^)]+)\)/) do |_text, target|
    next if target.include?("://") || target.start_with?("mailto:") || target.start_with?("#")

    # Clean query strings / anchors
    cleaned = target.split("#").first.split("?").first
    next if cleaned.empty?

    # Resolve relative to document dir or repo root
    resolved = if cleaned.start_with?("/")
                 ROOT.join(cleaned.sub(%r{^/}, ""))
               else
                 Pathname.new(File.dirname(doc_file)).join(cleaned)
               end

    unless File.exist?(resolved)
      error("#{rel_doc}: Broken link to '#{target}' (resolved: #{resolved})")
      broken_links += 1
    end
  end
end

if broken_links.zero?
  pass "All internal documentation links point to existing targets."
end

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
puts "=" * 70
puts "Invariant Check Summary:"
puts " Total Errors:   #{ERRORS.size}"
puts " Total Warnings: #{WARNINGS.size}"
puts "=" * 70

if ERRORS.any?
  puts "\nFAILED: Invariant violations detected. Please fix the above errors."
  exit 1
else
  puts "\nSUCCESS: All repository invariants verified."
  exit 0
end
