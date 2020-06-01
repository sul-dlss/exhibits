# frozen_string_literal: true

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

        # Select conventional file images or virtual external ones
        images = content_metadata.xpath(
          '(resource/file[@mimetype="image/jp2"] | resource/externalFile[@mimetype="image/jp2"])'
        )
        # Allow for selection of conventional ids and fileId for virtual objects
        jp2s = images.select { |node| (node.attr('id') || node.attr('fileId') || '').end_with?('jp2') }

        jp2s.each do |v|
          # Select a virtual object druid if available or the bare druid for a conventional image object
          druid = v.attr('objectId').to_s.delete_prefix('druid:')
          druid = resource.bare_druid if druid.empty?
          accumulator << stacks_iiif_url(druid, (v.attr('id') || v.attr('fileId') || '').delete_suffix('.jp2'))
        end
      end
    end

    private

    def stacks_iiif_url(bare_druid, file_name)
      "#{Settings.stacks.iiif_url}/#{bare_druid}%2F#{ERB::Util.url_encode(file_name)}"
    end
  end
end
