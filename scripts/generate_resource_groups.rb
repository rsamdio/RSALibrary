#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates _resources/*.md from files under resources/. Run from repo root:
#   ruby scripts/generate_resource_groups.rb

require "yaml"
require "pathname"
require "fileutils"
require "set"

ROOT = Pathname.new(__dir__).join("..").expand_path
RES = ROOT.join("resources")
OUT = ROOT.join("_resources")

MEDIA_EXT = %w[.png .pdf .svg .jpg .jpeg .webp].freeze

def url_path(rel)
  "/resources/#{rel}"
end

def type_icon_for(ext)
  case ext
  when ".pdf" then "picture_as_pdf"
  when ".svg", ".png", ".jpg", ".jpeg", ".webp" then "image"
  else "description"
  end
end

def titleize_basename(base)
  base.gsub(/[_-]+/, " ").split.map { |w| w.capitalize }.join(" ")
end

def bn_flat(rel)
  File.basename(rel)
end

# Human-friendly card name (all assets live in flat resources/)
def card_name(rel_path)
  base = File.basename(rel_path, ".*")
  bn = bn_flat(rel_path)

  if bn.match?(/\Arotary\.png\z/i) || bn.start_with?("rotary_")
    return titleize_basename(base)
  end

  if bn.match?(/\Arotaract\.png\z/i) || bn.start_with?("rotaract_")
    return titleize_basename(base)
  end

  if bn.match?(/\Ainteract\.png\z/i) || bn.start_with?("interact_")
    return titleize_basename(base)
  end

  if bn.start_with?("markofexcellence")
    return "Mark of Excellence — #{titleize_basename(base.sub(/^markofexcellence_?/i, ''))}"
  end

  titleize_basename(base)
end

def card_description(rel_path)
  base = File.basename(rel_path, ".*").downcase
  bn = bn_flat(rel_path)
  parts = []
  parts << "Full color" if base.include?("color") || base.include?("cmyk") || base.include?("_c.") || base.end_with?("_c")
  parts << "Reversed" if base.include?("rev")
  parts << "Black" if base.include?("black")
  parts << "White" if base.include?("white")
  parts << "Azure" if base.include?("azure")
  parts << "Gold accent" if base.include?("gold")
  parts << "Simplified mark" if base.include?("simple")
  parts << "Standard mark" if bn.match?(/\Arotaract\.png\z/i) || base == "rotaract"
  if bn.start_with?("AOF_group_")
    parts << "Group / composite AOF logo"
    parts << "Horizontal" if base.include?("horiz")
    parts << "Vertical" if base.include?("vertical")
    parts << "Circle" if base.include?("circle")
    parts << "No title lockup" if base.include?("no_title")
  end
  if %w[AOF_water_ AOF_education_ AOF_maternal_ AOF_peace_ AOF_economic_ AOF_disease_ AOF_environment_].any? { |p| bn.start_with?(p) }
    parts << "Side title" if base.include?("side_title")
    parts << "Bottom title" if base.include?("bottom_title") || base.include?("bottom_tile")
    parts << "No title" if base.include?("no_title")
    parts << "Reversed treatment" if base.include?("_rev_") || base.include?("rev_rgb")
  end
  if !bn.include?("/") && (base.include?("rotary") || base.include?("rotaract") || base.include?("interact"))
    parts << "Official Rotary International asset"
  end
  parts << "PDF document" if bn.end_with?(".pdf")
  parts.uniq.join(". ").squeeze(".")
end

def card_yaml_entry(rel)
  ext = File.extname(rel).downcase
  type = ext.delete(".").upcase
  type = "JPEG" if type == "JPG"
  u = url_path(rel)
  {
    "name" => card_name(rel),
    "description" => card_description(rel),
    "type" => type,
    "type_icon" => type_icon_for(ext),
    "preview_image_url" => (ext == ".pdf" ? nil : u),
    "view_url" => u,
    "download_url" => u
  }
end

def rel_from_abs(abs)
  Pathname.new(abs).relative_path_from(RES).to_s.tr("\\", "/")
end

# Collect all media files
all_files = []
Dir.glob(RES.join("**", "*")).each do |abs|
  next unless File.file?(abs)
  next unless MEDIA_EXT.include?(File.extname(abs).downcase)

  all_files << rel_from_abs(abs)
end
all_files.sort!

ASSIGNED = Set.new

def take_matching(files, &block)
  files.select do |rel|
    next false if ASSIGNED.include?(rel)

    block.call(rel)
  end.tap { |xs| xs.each { |r| ASSIGNED << r } }
end

# Flat resources/: filenames only (no subfolders). illustratives use PascalCase after AOF_; lockups use lowercase segments.
AOF_OVERVIEW_BASENAMES = %w[
  AOF_BasicEducationLiteracy.png
  AOF_CommunityEconomicDevelopment.png
  AOF_DiseasePreventionTreatment.png
  AOF_MaternalChildHealth.png
  AOF_PeaceAndConflictResolution.png
  AOF_WaterSanitation.png
  AOF_guidelines_EN21.pdf
].freeze

GROUP_DEFS = [
  {
    slug: "area-of-focus-water-sanitation",
    title: "Area of focus — water & sanitation",
    icon: "water_drop",
    icon_color: "sky",
    summary: "WASH / water and sanitation AOF mark lockups for Rotaract collateral.",
    nav_order: 70,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_water_") }
  },
  {
    slug: "area-of-focus-basic-education-literacy",
    title: "Area of focus — basic education & literacy",
    icon: "menu_book",
    icon_color: "violet",
    summary: "Basic education and literacy AOF mark lockups.",
    nav_order: 80,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_education_") }
  },
  {
    slug: "area-of-focus-maternal-child-health",
    title: "Area of focus — maternal & child health",
    icon: "child_care",
    icon_color: "rose",
    summary: "Maternal and child health AOF mark lockups.",
    nav_order: 90,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_maternal_") }
  },
  {
    slug: "area-of-focus-peacebuilding-conflict-prevention",
    title: "Area of focus — peacebuilding & conflict prevention",
    icon: "volunteer_activism",
    icon_color: "purple",
    summary: "Peacebuilding and conflict prevention AOF mark lockups.",
    nav_order: 100,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_peace_") }
  },
  {
    slug: "area-of-focus-community-economic-development",
    title: "Area of focus — community economic development",
    icon: "trending_up",
    icon_color: "orange",
    summary: "Community economic development AOF mark lockups.",
    nav_order: 110,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_economic_") }
  },
  {
    slug: "area-of-focus-disease-prevention-treatment",
    title: "Area of focus — disease prevention & treatment",
    icon: "vaccines",
    icon_color: "red",
    summary: "Disease prevention and treatment AOF mark lockups.",
    nav_order: 120,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_disease_") }
  },
  {
    slug: "area-of-focus-environment",
    title: "Area of focus — environment",
    icon: "forest",
    icon_color: "green",
    summary: "Environment AOF mark lockups.",
    nav_order: 130,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_environment_") }
  },
  {
    slug: "areas-of-focus-group-logos",
    title: "Areas of focus — group logos",
    icon: "join_inner",
    icon_color: "cyan",
    summary: "Composite Areas of Focus logos — horizontal, vertical, and circle layouts with color, black, white, and reverse treatments.",
    nav_order: 60,
    matcher: ->(rel) { bn_flat(rel).start_with?("AOF_group_") }
  },
  {
    slug: "areas-of-focus-overview",
    title: "Areas of focus — overview",
    icon: "grid_view",
    icon_color: "emerald",
    summary: "Illustrative Areas of Focus graphics and official AOF guidelines (English).",
    nav_order: 50,
    matcher: ->(rel) { AOF_OVERVIEW_BASENAMES.include?(bn_flat(rel)) }
  },
  {
    slug: "rotaract-masterbrand",
    title: "Rotaract masterbrand",
    icon: "diversity_3",
    icon_color: "blue",
    summary: "Official Rotaract program masterbrand marks — standard and simplified, multiple color treatments.",
    nav_order: 10,
    matcher: lambda { |rel|
      bn = bn_flat(rel)
      bn.match?(/\Arotaract\.png\z/i) || bn.start_with?("rotaract_")
    }
  },
  {
    slug: "rotary-masterbrand",
    title: "Rotary masterbrand",
    icon: "public",
    icon_color: "indigo",
    summary: "Official Rotary program masterbrand marks — standard and simplified, including azure and gold treatments.",
    nav_order: 20,
    matcher: lambda { |rel|
      bn = bn_flat(rel)
      bn.match?(/\Arotary\.png\z/i) || bn.start_with?("rotary_")
    }
  },
  {
    slug: "interact-masterbrand",
    title: "Interact masterbrand",
    icon: "school",
    icon_color: "teal",
    summary: "Official Interact program masterbrand marks for service projects and publications.",
    nav_order: 30,
    matcher: lambda { |rel|
      bn = bn_flat(rel)
      bn.match?(/\Ainteract\.png\z/i) || bn.start_with?("interact_")
    }
  },
  {
    slug: "rotary-mark-of-excellence",
    title: "Rotary Mark of Excellence",
    icon: "military_tech",
    icon_color: "amber",
    summary: "Rotary Mark of Excellence lockups — standard, azure, black, and white treatments.",
    nav_order: 40,
    matcher: ->(rel) { bn_flat(rel).start_with?("markofexcellence") }
  },
  {
    slug: "rsamdio-identity",
    title: "Rotaract South Asia MDIO identity",
    icon: "flag",
    icon_color: "fuchsia",
    summary: "Rotaract South Asia MDIO (RSAMDIO) logos and wordmarks for regional initiatives.",
    nav_order: 140,
    matcher: lambda { |rel|
      bn = bn_flat(rel)
      bn.match?(/\ARSAMDIO/i) || bn.match?(/\arsamdio_only/i) || bn.match?(/\ARsamdio/i)
    }
  },
  {
    slug: "official-program-marks",
    title: "Official program marks (CMYK & reverse)",
    icon: "approval",
    icon_color: "slate",
    summary: "Additional Rotary International program marks from the brand center — full-color CMYK, reversed, and specialty lockups.",
    nav_order: 145,
    matcher: lambda { |rel|
      next false if rel.include?("/")

      bn = bn_flat(rel)
      next false if bn.match?(/\ARSAMDIO/i) || bn.match?(/\arsamdio_only/i) || bn.match?(/\ARsamdio/i)

      File.extname(bn).downcase == ".png"
    }
  },
  {
    slug: "library-reference-documents",
    title: "Reference documents",
    icon: "description",
    icon_color: "lime",
    summary: "PDF guides, membership tools, and reference packets from Rotary International.",
    nav_order: 150,
    matcher: lambda { |rel|
      next false if rel.include?("/")

      File.extname(rel).downcase == ".pdf"
    }
  }
].freeze

FileUtils.mkdir_p(OUT)

written = []
GROUP_DEFS.each do |defn|
  rels = take_matching(all_files, &defn[:matcher])
  cards = rels.map { |r| card_yaml_entry(r) }

  doc = {
    "title" => defn[:title],
    "icon" => defn[:icon],
    "icon_color" => defn[:icon_color],
    "summary" => defn[:summary],
    "nav_order" => defn[:nav_order],
    "resources" => cards
  }

  yaml = doc.to_yaml(line_width: -1)
  path = OUT.join("#{defn[:slug]}.md")
  File.write(path, "#{yaml}---\n")
  written << [defn[:slug], cards.size]
end

unassigned = all_files.reject { |r| ASSIGNED.include?(r) }
unless unassigned.empty?
  warn "WARNING: unassigned files (#{unassigned.size}):"
  unassigned.each { |u| warn "  #{u}" }
  exit 1
end

puts "Wrote #{written.size} resource group files under #{OUT}:"
written.each { |slug, n| puts "  #{slug}.md — #{n} cards" }
