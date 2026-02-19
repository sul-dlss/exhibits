# frozen_string_literal: true

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
to_field 'last_updated', ->(resource, accumulator) { accumulator << resource.cocina_record.modified_time.utc.iso8601 }

# ITEM FIELDS
to_field 'display_type', conditional(->(resource, *_) { !resource.collection? }, accumulate { |resource, *_| display_type(resource) })

to_field 'collection', (accumulate { |resource, *_| resource.collections.map(&:bare_druid) })
to_field 'collection_with_title', (accumulate do |resource, *_|
  resource.collections.map { |collection| "#{collection.bare_druid}-|-#{coll_title(collection)}" }
end)
to_field 'collection_titles_ssim', (accumulate do |resource, *_|
  resource.collections.map { |collection| coll_title(collection) }
end)

to_field 'folio_hrid_ss', ->(resource, accumulator) { accumulator << resource.cocina_record.folio_hrid }

# COLLECTION FIELDS
to_field 'format_main_ssim', conditional(->(resource, *_) { resource.collection? }, literal('Collection'))
to_field 'collection_type', conditional(->(resource, *_) { resource.collection? }, literal('Digital Collection'))

# OTHER FIELDS
to_field 'url_fulltext', cocina_display(:purl_url)

# title fields
to_field 'title_245a_search', cocina_display(:short_title)
to_field 'title_245_search', cocina_display(:full_title)
to_field 'title_variant_search', cocina_display(:additional_titles)
to_field 'title_sort', cocina_display(:sort_title)
to_field 'title_245a_display', cocina_display(:short_title)
to_field 'title_display', cocina_display(:display_title)

to_field 'name_ssim' do |resource, accumulator|
  resource.cocina_record.contributors.reject(&:publisher?).each do |contributor|
    accumulator << contributor.display_name(with_date: true)
  end
end

to_field 'name_roles_ssim' do |resource, accumulator|
  resource.cocina_record.contributors.reject(&:publisher?).each do |contributor|
    if contributor.roles.present?
      contributor.roles.each do |role|
        accumulator << "#{role.to_s.upcase_first}|#{contributor.display_name(with_date: true)}"
      end
    else
      accumulator << "|#{contributor.display_name(with_date: true)}"
    end
  end
end

# author fields
to_field 'author_1xx_search', cocina_display(:main_contributor_name, with_date: true)
to_field 'author_7xx_search', cocina_display(:additional_contributor_names, with_date: true)
to_field 'author_person_facet', cocina_display(:person_contributor_names, with_date: true)
to_field 'author_other_facet', cocina_display(:impersonal_contributor_names)
to_field 'author_sort', cocina_display(:sort_contributor_name) do |_record, accumulator|
  accumulator.map! { |v| v.tr("\uFFFF", "\uFFFD") }
end

to_field 'author_corp_display', cocina_display(:organization_contributor_names)
to_field 'author_meeting_display', cocina_display(:conference_contributor_names)
to_field 'author_person_display', cocina_display(:person_contributor_names, with_date: true)
to_field 'author_person_full_display', cocina_display(:person_contributor_names, with_date: true)
to_field 'author_no_collector_ssim' do |resource, accumulator|
  authors_without_collectors = resource.cocina_record.contributors.select(&:person?).reject do |c|
    c.roles.map(&:to_s).all?('collector')
  end

  accumulator.concat(authors_without_collectors.map { |c| c.display_name(with_date: true) })
end

to_field 'collector_ssim' do |resource, accumulator|
  collectors = resource.cocina_record.contributors.select(&:person?).select do |c|
    c.roles.map(&:to_s).any?('collector')
  end

  accumulator.concat(collectors.map { |c| c.display_name(with_date: true) })
end

# subject search fields
to_field 'topic_search', cocina_display(:subject_topics)
to_field 'geographic_search', cocina_display(:subject_places)
to_field 'subject_other_search', cocina_display(:subject_other)
to_field 'subject_other_subvy_search', cocina_display(:subject_temporal_genre)
to_field 'subject_all_search', cocina_display(:subject_all)
to_field 'topic_facet', cocina_display(:subject_topics_other)
to_field 'geographic_facet', cocina_display(:subject_places)
to_field 'era_facet', cocina_display(:subject_temporal)

to_field 'format_main_ssim', conditional(->(resource, *_) { !resource.collection? }, cocina_display(:searchworks_resource_types))

to_field 'language', cocina_display(:searchworks_language_names)
to_field 'physical', cocina_display(:extents)
to_field 'summary_search', cocina_display(:abstracts)
to_field 'toc_search', cocina_display(:tables_of_contents)

to_field 'url_suppl', (accumulate { |resource, *_| resource.cocina_record.related_resources.flat_map { it.urls.map(&:to_s) } })
to_field 'url_suppl', (accumulate { |resource, *_| resource.cocina_record.related_resources.map(&:purl_url) })
to_field 'url_suppl', (accumulate { |resource, *_| resource.cocina_record.containing_collections.map { "https://purl.stanford.edu/#{it}" } })

# publication fields
# Based on schema.xml, pub_search is also copied over to pub_display
to_field 'pub_search', cocina_display(:publication_places)
to_field 'pub_year_isi', cocina_display(:pub_year_int, ignore_qualified: false) # for sorting
# these are for single value facet display (in lieu of date slider (pub_year_tisim) )
to_field 'pub_year_no_approx_isi', cocina_display(:pub_year_int, ignore_qualified: true)
to_field 'pub_year_w_approx_isi', cocina_display(:pub_year_int, ignore_qualified: false)

to_field 'pub_year_tisim', cocina_display(:pub_year_ints)
to_field 'date_ssim', (accumulate { |resource, *_| resource.cocina_record.event_dates.map(&:qualified_value) })
to_field 'imprint_display', cocina_display(:imprint_str)

to_field 'publisher_ssim', cocina_display(:publisher_names)
to_field 'publisher_tesim', cocina_display(:publisher_names)
to_field 'publisher_ssi' do |_resource, accumulator, context|
  value = Array(context.output_hash['publisher_tesim']).first
  accumulator << value if value
end

# *_tsi fields get copied to all_search and all_unstem_search
to_field 'cocina_description_tsi', (accumulate { |resource, *_| resource.cocina_record.text })

to_field 'box_ssi', (accumulate { |resource, *_| resource.box })
to_field 'folder_ssi', (accumulate { |resource, *_| resource.folder })
to_field 'location_ssi', (accumulate { |resource, *_| resource.physical_location })
to_field 'series_ssi', (accumulate { |resource, *_| resource.series })

to_field 'genre_ssim', cocina_display(:genres_search)
to_field 'genre_ssim', cocina_display(:subject_genres)

to_field 'identifier_ssim', (accumulate { |resource, *_| resource.cocina_record.identifiers.map(&:value) })

# add coordinates solr field containing the cartographic coordinates
to_field 'coordinates_tesim', cocina_display(:coordinates)
to_field 'geographic_srpt', (accumulate { |resource, *_| resource.coordinates_as_envelope_or_points })

to_field 'geographic_srpt', (accumulate { |resource, *_| resource.cocina_record.geonames_ids }) do |_resource, accumulator, _context|
  accumulator.map! do |id|
    get_geonames_api_envelope(id)
  end

  accumulator.compact!
end

to_field 'iiif_manifest_url_ssi', (accumulate { |resource, *_| format ::Settings.purl.iiif_manifest_url, druid: resource.bare_druid })

# CONTENT METADATA

to_field 'content_metadata_type_ssim', cocina_display(:content_type)
to_field 'content_metadata_type_ssm', copy('content_metadata_type_ssim')

to_field 'content_metadata_image_iiif_info_ssm' do |resource, accumulator, _context|
  next if resource.thumbnail_identifier.blank?

  accumulator << "#{::Settings.stacks.iiif_url}/#{resource.thumbnail_identifier}/info.json"
end

to_field 'thumbnail_square_url_ssm', (accumulate { |resource, *_| resource.thumbnail_url(region: 'square', width: '100', height: '100') })
to_field 'thumbnail_url_ssm', (accumulate { |resource, *_| resource.thumbnail_url(width: '!400', height: '400') })
to_field 'large_image_url_ssm', (accumulate { |resource, *_| resource.thumbnail_url(width: '!1000', height: '1000') })
to_field 'full_image_url_ssm', (accumulate { |resource, *_| resource.thumbnail_url(width: '!3000', height: '3000') })

# FEIGENBAUM FIELDS

to_field 'doc_subtype_ssi', cocina_display_path('$.description.note[?(@.displayLabel == "Document subtype")].value')

to_field 'donor_tags_ssim', (accumulate do |resource, *_|
  resource.cocina_record.path('$.description.note[?(@.displayLabel == "Donor tags")].value').to_a.map(&:upcase_first)
end)

to_field 'folder_name_ssi' do |resource, accumulator, _context|
  preferred_citation = resource.cocina_record.path('$.description.note[?(@.type == "preferred citation")].value').to_a
  match_data = preferred_citation.first.match(/Title: +(.+)/i) if preferred_citation.present?
  accumulator << match_data[1].strip if match_data.present?
end

to_field 'general_notes_ssim' do |resource, accumulator, _context|
  resource.cocina_record.path('$.description.note.*').to_a.each do |note|
    next if note['type'].present? || note['displayLabel'].present?

    accumulator << note['value']
  end
end

# FULL TEXT FIELDS
to_field 'full_text_tesimv', (accumulate { |resource, *_| FullTextParser.new(resource).to_text })

# PARKER FIELDS

to_field 'manuscript_number_tesim', cocina_display_path('$.description..access.physicalLocation[?(@.type == "shelf locator")].value')
to_field 'incipit_tesim', cocina_display_path('$.description..note[?(@.type == "incipit")].value')
to_field 'repository_ssim', cocina_display_path('$.description.access.accessContact[?(@.type == "repository")].value')
to_field 'place_created_ssim', cocina_display(:publication_places)
to_field 'provenance_ssim', cocina_display_path('$.description..note[?(@.type == "provenance")].value')

to_field 'dimensions_ssim' do |resource, accumulator, _context|
  resource.cocina_record.path('$.description..note[?(@.type == "dimensions")]').each do |dimension|
    accumulator << [dimension['value'], dimension['displayLabel']].join(' ')
  end
end

to_field 'identifier_displayLabel_ssim' do |resource, accumulator, _context|
  resource.cocina_record.path('$.description.identifier.*').each do |identifier|
    accumulator << "#{identifier['displayLabel'] || identifier['type']}-|-#{identifier['value']}"
  end

  accumulator.sort!
end

# Fetch remote geonames metadata and format it for Solr
# @param [String] id geonames identifier
# @return [String] Solr WKT/CQL ENVELOPE based on //geoname/bbox
def get_geonames_api_envelope(id)
  url = "http://api.geonames.org/get?geonameId=#{id}&username=#{::Settings.geonames_username}"
  xml = Nokogiri::XML Faraday.get(url).body
  bbox = xml.at_xpath('//geoname/bbox')
  return if bbox.nil?

  min_x, max_x = [bbox.at_xpath('west').text.to_f, bbox.at_xpath('east').text.to_f].minmax
  min_y, max_y = [bbox.at_xpath('north').text.to_f, bbox.at_xpath('south').text.to_f].minmax
  "ENVELOPE(#{min_x},#{max_x},#{max_y},#{min_y})"
rescue Faraday::Error => e
  logger.error("Error fetching/parsing #{url} -- #{e.message}")
  nil
end

def display_type(resource)
  case resource.cocina_record.content_type
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
