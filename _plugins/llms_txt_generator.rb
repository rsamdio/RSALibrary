# frozen_string_literal: true

# Writes /llms.txt into the build output only.
# Do NOT write into site.source — that retriggers jekyll --watch forever.

module Jekyll
  class LlmsTxtGenerator < Generator
    safe true
    priority :low

    def generate(site)
      site.config["llms_txt_content"] = self.class.build_text(site)
    end

    def self.build_text(site)
      meta = site.data["site"] || {}
      product_name = meta["product_name"] || site.config["title"] || "Rotaract Library"
      product_desc = meta["product_description"] || site.config["description"].to_s
      publisher = meta["publisher_name"] || "Rotaract South Asia MDIO"
      publisher_short = meta["publisher_short"] || "RSAMDIO"
      email = meta["publisher_email"] || "rsamdio@gmail.com"
      base = (site.config["url"].to_s + site.config["baseurl"].to_s).sub(%r{/$}, "")
      base = "https://library.rsamdio.org" if base.empty?

      lines = []
      lines << "# #{product_name}"
      lines << "> #{product_desc}"
      lines << ""
      lines << "## Publisher"
      lines << "- #{publisher} (#{publisher_short})"
      lines << "- Contact: #{email}"
      lines << "- AI crawlers: allowed (ai_bots_policy: #{meta['ai_bots_policy'] || 'allow'})"
      lines << ""
      lines << "## Primary pages"
      lines << "- Home: #{base}/"
      lines << "- About: #{base}/about/"
      lines << "- FAQ: #{base}/faq/"
      lines << "- Request a resource: #{base}/request/"
      lines << "- Public resources feed (JSON): #{base}/resources.json"
      lines << ""
      lines << "## Resource collections"

      resources = (site.collections["resources"]&.docs || []).reject { |d| d.data["published"] == false }
      resources = resources.sort_by { |d| d.data["nav_order"].to_i }
      resources.each do |doc|
        title = doc.data["title"].to_s
        summary = doc.data["summary"].to_s.gsub(/\s+/, " ").strip
        url = "#{base}#{doc.url}"
        lines << "- #{title}: #{url} — #{summary}"
      end

      tools = site.data["tools"] || []
      if tools.any?
        lines << ""
        lines << "## Related tools"
        tools.each do |tool|
          lines << "- #{tool['name']}: #{tool['url']} — #{tool['description']}"
        end
      end

      lines << ""
      lines << "## Notes"
      lines << "- Official Rotaract brand assets: #{base}/rotaract-brand-assets/"
      lines << "- Resources are indicative templates; verify before official use."
      lines << ""
      lines.join("\n")
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  text = site.config["llms_txt_content"]
  text = Jekyll::LlmsTxtGenerator.build_text(site) if text.nil? || text.empty?
  File.write(File.join(site.dest, "llms.txt"), text)
end
