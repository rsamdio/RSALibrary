# frozen_string_literal: true

require "json"
require "fileutils"

# Writes /resources.json into the build output only.
# Do NOT write into site.source (prevents jekyll --watch rebuild loops).

module Jekyll
  class ResourcesFeedGenerator
    def self.build_feed(site)
      site_meta = site.data["site"] || {}
      base = (site_meta["product_url"] || site.config["url"].to_s).sub(%r{/$}, "")
      base = "https://library.rsamdio.org" if base.empty?

      title = site_meta["product_name"] || site.config["title"] || "Rotaract Library"
      description = site_meta["product_description"] || site.config["description"].to_s

      docs = (site.collections["resources"]&.docs || []).reject do |d|
        d.data["published"] == false || d.relative_path.include?("template.md")
      end

      sorted_docs = docs.sort_by { |d| d.data["nav_order"].to_i }

      groups_output = []
      flat_resources = []

      sorted_docs.each do |doc|
        d = doc.data
        group_slug = doc.basename_without_ext
        canonical_group_url = "#{base}/#{group_slug}/"
        group_title = clean_text(d["title"])
        group_summary = clean_text(d["summary"])

        group_items = []

        # 1. Top-level resources
        (d["resources"] || []).each do |item|
          res = build_resource_item(item, group_title, canonical_group_url, group_slug, nil, base)
          group_items << res
          flat_resources << res
        end

        # 2. Subgroup resources
        (d["subgroups"] || []).each do |subgroup|
          sg_title = clean_text(subgroup["title"])
          (subgroup["resources"] || []).each do |item|
            res = build_resource_item(item, group_title, canonical_group_url, group_slug, sg_title, base)
            group_items << res
            flat_resources << res
          end
        end

        groups_output << {
          "id" => group_slug,
          "title" => group_title,
          "summary" => group_summary,
          "url" => canonical_group_url,
          "icon" => d["icon"].to_s,
          "icon_color" => d["icon_color"].to_s,
          "resource_count" => group_items.size,
          "resources" => group_items
        }
      end

      {
        "title" => title,
        "description" => description,
        "home_url" => "#{base}/",
        "feed_url" => "#{base}/resources.json",
        "generated_at" => site.time.xmlschema,
        "total_resources" => flat_resources.size,
        "groups" => groups_output,
        "resources" => flat_resources
      }
    end

    def self.build_resource_item(item, group_title, group_url, group_slug, subgroup_title, _base)
      item_name = clean_text(item["name"])
      item_desc = clean_text(item["description"])
      item_type = clean_text(item["type"])
      item_type = "Resource" if item_type.empty?

      id_slug = "#{group_slug}/#{slugify(item_name)}"

      entry = {
        "id" => id_slug,
        "name" => item_name,
        "description" => item_desc,
        "type" => item_type,
        "group_title" => group_title,
        "group_url" => group_url,
        "url" => group_url
      }

      entry["subgroup"] = subgroup_title if subgroup_title && !subgroup_title.empty?

      entry
    end

    def self.clean_text(val)
      return "" if val.nil?

      s = val.to_s.gsub(/<[^>]*>/, " ")
      s.gsub(/\s+/, " ").strip
    end

    def self.slugify(val)
      val.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  payload = Jekyll::ResourcesFeedGenerator.build_feed(site)
  out_path = File.join(site.dest, "resources.json")
  FileUtils.mkdir_p(File.dirname(out_path))
  File.write(out_path, JSON.pretty_generate(payload), encoding: "utf-8")
  Jekyll.logger.info "ResourcesFeed:", "Wrote #{payload['total_resources']} resources to resources.json"
end
