# frozen_string_literal: true

# Post-process sitemap.xml to drop /admin/ and binary asset landings under /resources/.
Jekyll::Hooks.register :site, :post_write do |site|
  sitemap_path = File.join(site.dest, "sitemap.xml")
  next unless File.file?(sitemap_path)

  content = File.read(sitemap_path)
  filtered = content.gsub(%r{<url>\s*<loc>[^<]*(?:/admin/|/resources/[^<]*\.(?:pdf|png|jpg|jpeg|webp|svg|ai|gif|zip|pptx?|docx?|xlsx?))</loc>.*?</url>}im, "")
  File.write(sitemap_path, filtered) if filtered != content
end
