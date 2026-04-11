# frozen_string_literal: true

module Jekyll
  module SearchIndexBuilder
    module_function

    def build_documents(site)
      list = []
      id = 0
      baseurl = site.config["baseurl"].to_s
      md_converter = site.find_converter_instance(Jekyll::Converters::Markdown)

      site.pages.each do |page|
        next if page.url == "/"
        next if page.url&.include?(".xml")
        next if page.url&.include?("assets")
        next if page.data["search_exclude"] == true

        body = normalize_body(md_converter.convert(page.content))
        list << {
          "id" => id,
          "type" => "page",
          "url" => "#{baseurl}#{page.url}",
          "title" => page.data["title"] || page.url,
          "body" => body
        }
        id += 1
      end

      (site.collections["resources"]&.docs || []).each do |resource|
        next if resource.data["published"] == false

        d = resource.data
        resource_text = d["summary"].to_s
        (d["resources"] || []).each do |item|
          resource_text += " #{item["name"]} #{item["description"]}"
        end

        list << {
          "id" => id,
          "type" => "group",
          "url" => "#{baseurl}#{resource.url}",
          "title" => d["title"].to_s,
          "body" => normalize_body(resource_text)
        }
        id += 1

        (d["resources"] || []).each do |item|
          raw_view = item["view_url"]
          raw_download = item["download_url"].to_s
          raw_preview = item["preview_image_url"]

          view_href = resolve_url(site, baseurl, raw_view)
          download_href = raw_download.empty? ? nil : resolve_url(site, baseurl, raw_download)
          preview_src = resolve_url(site, baseurl, raw_preview)

          primary_url = view_href || download_href || "#{baseurl}#{resource.url}"

          list << {
            "id" => id,
            "type" => "resource",
            "group_title" => d["title"].to_s,
            "group_url" => "#{baseurl}#{resource.url}",
            "url" => primary_url,
            "title" => item["name"].to_s,
            "body" => normalize_body(item["description"].to_s),
            "preview_image_url" => preview_src,
            "view_url" => view_href,
            "download_url" => download_href,
            "download_suggested_name" => download_suggested_filename(item, download_href)
          }
          id += 1
        end
      end

      list
    end

    def normalize_body(html)
      strip = html.gsub(/<[^>]*>/, "").gsub(/\s+/, " ").strip
      strip.gsub("  ", " ")
    end

    def resolve_url(_site, baseurl, raw)
      return nil if raw.nil? || raw.to_s.empty?

      s = raw.to_s
      return s if s.include?("://")

      path = s.start_with?("/") ? s : "/#{s}"
      "#{baseurl}#{path}"
    end

    def download_suggested_filename(item, download_href)
      return nil if download_href.nil? || download_href.empty?

      base = sanitize_download_base(item["name"].to_s)
      tail = download_href.split("?").first.split("/").last
      return base unless tail.include?(".")

      ext = tail.split(".").last.downcase
      "#{base}.#{ext}"
    end

    def sanitize_download_base(name)
      n = name.strip
      n = n.gsub(%r{[<>:/\\|?*&]}, " ")
      n = n.gsub(/["']/, "")
      n = n.gsub("&", " and ")
      n.squeeze(" ").strip
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  docs = Jekyll::SearchIndexBuilder.build_documents(site)
  path = File.join(site.dest, "assets", "js", "search-index.json")
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, JSON.generate(docs))
  Jekyll.logger.info "SearchIndex:", "Wrote #{docs.length} entries to assets/js/search-index.json"
end
