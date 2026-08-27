#!/usr/bin/env ruby
# frozen_string_literal: true

# Synchronizes index.md repository manifest and detects documentation drift.
#
# Usage:
#   ruby scripts/agent/sync_index.rb          # Updates index.md manifest
#   ruby scripts/agent/sync_index.rb --check  # Checks for drift (exits 1 if drift found)

require "yaml"
require "pathname"

ROOT = Pathname.new(__dir__).join("../..").expand_path
INDEX_PATH = ROOT.join("index.md")

# 1. Collect repository metrics
resource_group_files = Dir.glob(ROOT.join("_resources", "*.md")).sort
resource_cards_count = 0
group_summaries = []

resource_group_files.each do |f|
  content = File.read(f, encoding: "utf-8")
  parts = content.split("---", 3)
  next if parts.size < 3

  data = YAML.safe_load(parts[1]) || {}
  slug = File.basename(f, ".md")
  title = data["title"] || slug
  order = data["nav_order"] || 999
  cards = (data["resources"] || []).size
  (data["subgroups"] || []).each do |sg|
    cards += (sg["resources"] || []).size
  end
  resource_cards_count += cards
  group_summaries << {
    slug: slug,
    title: title,
    order: order,
    cards: cards,
    icon: data["icon"],
    icon_color: data["icon_color"]
  }
end

group_summaries.sort_by! { |g| [g[:order].to_i, g[:title]] }

asset_files = Dir.glob(ROOT.join("resources", "*")).select { |f| File.file?(f) }
plugin_files = Dir.glob(ROOT.join("_plugins", "*.rb")).map { |f| File.basename(f) }.sort
layout_files = Dir.glob(ROOT.join("_layouts", "*.html")).map { |f| File.basename(f) }.sort
include_files = Dir.glob(ROOT.join("_includes", "*.html")).map { |f| File.basename(f) }.sort
data_files = Dir.glob(ROOT.join("_data", "*.yml")).map { |f| File.basename(f) }.sort

tools_file = ROOT.join("_data", "tools.yml")
tools_count = File.file?(tools_file) ? (YAML.safe_load(File.read(tools_file, encoding: "utf-8")) || []).size : 0

# 2. Build the Manifest Markdown Block
manifest_lines = []
manifest_lines << "<!-- MANIFEST:START -->"
manifest_lines << "### Machine-Verifiable Repository Manifest"
manifest_lines << ""
manifest_lines << "| Metric | Count | Details / Path |"
manifest_lines << "| :--- | :--- | :--- |"
manifest_lines << "| **Resource Groups** | #{group_summaries.size} | `_resources/*.md` |"
manifest_lines << "| **Resource Cards** | #{resource_cards_count} | Embedded in resource groups |"
manifest_lines << "| **Static Assets** | #{asset_files.size} | `resources/` (Pure ASCII filenames) |"
manifest_lines << "| **Ecosystem Tools** | #{tools_count} | `_data/tools.yml` |"
manifest_lines << "| **Custom Plugins** | #{plugin_files.size} | `_plugins/` (#{plugin_files.join(', ')}) |"
manifest_lines << "| **Layout Templates** | #{layout_files.size} | `_layouts/` (#{layout_files.join(', ')}) |"
manifest_lines << "| **Includes** | #{include_files.size} | `_includes/` |"
manifest_lines << "| **Data Files** | #{data_files.size} | `_data/` (#{data_files.join(', ')}) |"
manifest_lines << ""
manifest_lines << "#### Active Resource Groups"
manifest_lines << ""
manifest_lines << "| Nav Order | Title | Slug | Cards | Icon & Color |"
manifest_lines << "| :--- | :--- | :--- | :--- | :--- |"
group_summaries.each do |g|
  manifest_lines << "| #{g[:order]} | #{g[:title]} | `#{g[:slug]}` | #{g[:cards]} | `#{g[:icon]}` (#{g[:icon_color]}) |"
end
manifest_lines << "<!-- MANIFEST:END -->"

generated_manifest = manifest_lines.join("\n")

# 3. Check or Update index.md
unless File.file?(INDEX_PATH)
  puts "[WARN] index.md does not exist yet. Run sync_index.rb again after creating index.md."
  exit 0
end

index_content = File.read(INDEX_PATH, encoding: "utf-8")

check_mode = ARGV.include?("--check")

if index_content.include?("<!-- MANIFEST:START -->") && index_content.include?("<!-- MANIFEST:END -->")
  current_manifest = index_content[/<!-- MANIFEST:START -->.*?<!-- MANIFEST:END -->/m]

  if current_manifest == generated_manifest
    puts "[PASS] index.md manifest is up to date with repository state."
    exit 0
  elsif check_mode
    puts "[ERROR] Drift detected in index.md manifest! Run 'ruby scripts/agent/sync_index.rb' to synchronize."
    exit 1
  else
    updated_content = index_content.sub(/<!-- MANIFEST:START -->.*?<!-- MANIFEST:END -->/m, generated_manifest)
    File.write(INDEX_PATH, updated_content, encoding: "utf-8")
    puts "[UPDATED] index.md manifest synchronized successfully."
    exit 0
  end
else
  if check_mode
    puts "[ERROR] index.md is missing MANIFEST markers."
    exit 1
  else
    puts "[INFO] Appending manifest to index.md..."
    File.write(INDEX_PATH, "#{index_content.strip}\n\n#{generated_manifest}\n", encoding: "utf-8")
    puts "[UPDATED] Appended manifest to index.md."
    exit 0
  end
end
