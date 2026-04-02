# frozen_string_literal: true

# Runs Tailwind before the site is processed so `bundle exec jekyll build` (and serve)
# always has a fresh assets/css/site.css. Requires `npm install` once for node_modules.

Jekyll::Hooks.register :site, :after_reset do |site|
  next if ENV["SKIP_TAILWIND_BUILD"] == "1" || ENV["SKIP_TAILWIND_BUILD"] == "true"

  source = site.source
  pkg = File.join(source, "package.json")
  next unless File.file?(pkg)

  unless File.directory?(File.join(source, "node_modules"))
    Jekyll.logger.abort_with(
      "Tailwind:",
      "node_modules missing. Run `npm install` in the repo root, then try again."
    )
  end

  Jekyll.logger.info "Tailwind:", "Compiling CSS…"
  Dir.chdir(source) do
    ok = system("npm", "run", "build:css", exception: false)
    unless ok
      Jekyll.logger.abort_with("Tailwind:", "npm run build:css failed.")
    end
  end
end
