# frozen_string_literal: true

# Traject configuration for indexing DOR resources into Solr.
# Used by both the MODS and Cocina Traject configs since
# these fields are always derived from Cocina and are the same
# regardless of the metadata format.

require_relative 'macros/general'
require_relative 'macros/dor'

require 'active_support/core_ext/object/blank'
extend Traject::Macros::General
extend Traject::Macros::Dor

settings do
  provide 'reader_class_name', 'DorReader'
  provide 'processing_thread_pool', ::Settings.traject.processing_thread_pool || 1
end

to_fields %w(id druid), (accumulate { |resource, *_| resource.bare_druid })
to_field 'last_updated', (accumulate { |resource, *_| resource.last_updated })

# ITEM FIELDS
to_field 'display_type', conditional(->(resource, *_) { !resource.collection? }, accumulate { |resource, *_|
  display_type(resource)
})

to_field 'collection', (accumulate { |resource, *_| resource.collections.map(&:bare_druid) })
to_field 'collection_with_title', (accumulate do |resource, *_|
  resource.collections.map { |collection| "#{collection.bare_druid}-|-#{coll_title(collection)}" }
end)
to_field 'collection_titles_ssim', (accumulate do |resource, *_|
  resource.collections.map { |collection| coll_title(collection) }
end)

# COLLECTION FIELDS
to_field 'format_main_ssim', conditional(->(resource, *_) { resource.collection? }, literal('Collection'))
to_field 'collection_type', conditional(->(resource, *_) { resource.collection? }, literal('Digital Collection'))

# OTHER FIELDS
to_field 'url_fulltext', (accumulate { |resource, *_| "https://purl.stanford.edu/#{resource.bare_druid}" })

to_field 'iiif_manifest_url_ssi', (accumulate { |resource, *_| iiif_manifest_url(resource.bare_druid) })

# CONTENT METADATA
to_field 'content_metadata_type_ssim', cocina_display(:content_type)

to_field 'content_metadata_type_ssm', copy('content_metadata_type_ssim')

to_field 'content_metadata_image_iiif_info_ssm', resource_images_iiif_urls do |_resource, accumulator, _context|
  accumulator.map! { |base_url| "#{base_url}/info.json" }
end

to_field 'thumbnail_square_url_ssm', resource_images_iiif_urls do |_resource, accumulator, _context|
  accumulator.map! { |base_url| "#{base_url}/square/100,100/0/default.jpg" }
end

to_field 'thumbnail_url_ssm', resource_images_iiif_urls do |_resource, accumulator, _context|
  accumulator.map! { |base_url| "#{base_url}/full/!400,400/0/default.jpg" }
end

to_field 'large_image_url_ssm', resource_images_iiif_urls do |_resource, accumulator, _context|
  accumulator.map! { |base_url| "#{base_url}/full/!1000,1000/0/default.jpg" }
end

to_field 'full_image_url_ssm', resource_images_iiif_urls do |_resource, accumulator, _context|
  accumulator.map! { |base_url| "#{base_url}/full/!3000,3000/0/default.jpg" }
end

# FULL TEXT FIELDS
to_field 'full_text_tesimv', (accumulate { |resource, *_| FullTextParser.new(resource).to_text })

def display_type(resource)
  case resource.cocina_record&.content_type
  when 'book'
    'book'
  when 'image', 'manuscript', 'map'
    'image'
  else
    'file'
  end
end

def coll_title(resource)
  @collection_titles ||= {}
  @collection_titles[resource.druid] ||= resource.cocina_record.label
end

def iiif_manifest_url(bare_druid)
  format ::Settings.purl.iiif_manifest_url, druid: bare_druid
end
