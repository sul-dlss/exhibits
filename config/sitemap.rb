require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = "#{Settings.host}#{Settings.base_path}"
SitemapGenerator::Interpreter.send :include, Rails.application.routes.url_helpers
SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers
SitemapGenerator::Sitemap.create do
  Spotlight::Exhibit.find_each do |exhibit|
    add exhibit_root_path(exhibit)

    exhibit.feature_pages.published.find_each do |p|
      add exhibit_feature_page_path(exhibit, p), priority: 0.8, lastmod: p.updated_at
    end

    exhibit.about_pages.published.find_each do |p|
      add exhibit_about_page_path(exhibit, p), priority: 0.5, lastmod: p.updated_at
    end

    exhibit.searches.published.find_each do |s|
      add exhibit_browse_path(exhibit, s), priority: 0.5, lastmod: s.updated_at
    end
    class Things
      def initialize(blacklight_config)
        @repository = Blacklight::SolrRepository.new(blacklight_config)
      end

      def find_each
        return to_enum(:find_each) unless block_given?

        start = 0
        response = @repository.search(q: '*:*', fl: '*', start: 0)
        while response.docs.present?
          response.docs.each do |x|
            yield x
          end
          start += response.docs.length
          response = @repository.search(q: '*:*', fl: '*', start: start)
        end
      end
    end

    Things.new(exhibit.blacklight_config).find_each do |i|
      lastmod = Time.parse(i[exhibit.blacklight_config.index.timestamp_field]) if i[exhibit.blacklight_config.index.timestamp_field]
      add exhibit_catalog_path(exhibit, SolrDocument.new(i)), priority: 0.25, lastmod: lastmod || Time.now
    end
  end
end
