module Macros
  # Macros for working with DOR objects
  module Dor
    def stanford_mods(method, *args)
      lambda do |resource, accumulator, _context|
        Array(resource.smods_rec.public_send(method, *args)).each do |v|
          accumulator << v
        end
      end
    end

    def resource_images_iiif_urls
      lambda do |resource, accumulator, _context|
        content_metadata = resource.public_xml.at_xpath('/publicObject/contentMetadata')
        next if content_metadata.nil?

        images = content_metadata.xpath('resource/file[@mimetype="image/jp2"]')
        jp2s = images.select { |node| node.attr('id') =~ /jp2$/ }

        jp2s.each do |v|
          accumulator << stacks_iiif_url(resource.bare_druid, v.attr('id').gsub('.jp2', ''))
        end
      end
    end

    private

    def stacks_iiif_url(bare_druid, file_name)
      "#{Settings.stacks.iiif_url}/#{bare_druid}%2F#{file_name}"
    end
  end
end
