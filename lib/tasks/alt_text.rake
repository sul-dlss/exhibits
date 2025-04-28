# frozen_string_literal: true

require 'csv'

# rubocop:disable Metrics/BlockLength
namespace :alt_text do
  # Used to extract images that do not have alt text from exhibits for use in AI label experiment
  # Put list of exhibit titles in a file called tmp/exhibits.csv, one title per line (no header)
  # The output will be written to a file called tmp/images.csv
  # see https://github.com/sul-dlss/exhibits/issues/2816
  # and https://docs.google.com/document/d/1Ryni3j19v6wKMwqfDmKYzIElDsY4lFGfJhbeezVPJ4I
  desc 'Export images that do not have alt text from specified exhibits'
  task export_images: :environment do
    base_url = 'https://exhibits.stanford.edu'
    Spotlight::Engine.routes.default_url_options[:host] = base_url

    exhibits_filename = 'tmp/exhibits.csv' # a file with one line per exhibit title to export (no header)
    output_filename = 'tmp/images.csv' # a file to write the output to
    output_image_folder = 'tmp/images' # a folder to write the images to

    raise "Exhibit list file #{exhibits_filename} not found" unless File.exist?(exhibits_filename)

    exhibit_titles = File.readlines(exhibits_filename).map(&:strip)
    total_exhibits = exhibit_titles.size
    puts "Exporting images from #{total_exhibits} exhibits listed in #{exhibits_filename} to #{output_filename}"
    exhibits = Spotlight::Exhibit.where(title: exhibit_titles)
    CSV.open(output_filename, 'wb') do |csv|
      csv << ['Exhibit', 'Exhibit description', 'Page title', 'Extra Text', 'image caption', 'exhibit slug',
              'page slug', 'page url', 'image url']
      puts "Found #{exhibits.size} exhibits"
      exhibits.each do |exhibit|
        puts "Exporting images from exhibit: #{exhibit.title}"
        pages_with_alt = exhibit.pages.order(Arel.sql('id = 1 DESC, created_at DESC')).select do |elem|
          elem.content.any?(&:supports_alt_text?)
        end
        pages_with_alt.each do |page|
          page.content.each do |block|
            next unless block.supports_alt_text?

            route_parts = [exhibit]
            route_parts << page unless page.is_a?(Spotlight::HomePage)
            page_url = Spotlight::Engine.routes.url_helpers.url_for(route_parts)

            extra_text = block.text # description (may be nil or empty) of image
            images = block.item || {}
            images_without_alt = images.values.select { |img| img['alt_text'].blank? && img['decorative'].blank? }
            images_without_alt.each do |img|
              url = img['url'] || img['full_image_url'].presence ||
                    img['iiif_tilesource'].sub('info.json', '/full/!400,400/0/default.jpg')
              next if url.blank? || url == 'undefined' # Likely a media item. Not an image.

              csv << [exhibit.title, exhibit.description, page.title, extra_text, img['caption'], exhibit.slug,
                      page.slug, page_url, url]
            end
          end
        end
      end
    end

    puts "Downloading images from #{output_filename} to #{output_image_folder}"
    FileUtils.mkdir_p(output_image_folder)

    CSV.foreach(output_filename, headers: true).with_index(1) do |row, n|
      url = row['image url']
      url = "{#base_url}#{url}" unless url.start_with?('https://')
      puts "Exporting image #{n}: #{url}"
      `curl -s #{url} -o #{output_image_folder}/#{n}.jpg`
    end
  end
end
# rubocop:enable Metrics/BlockLength
