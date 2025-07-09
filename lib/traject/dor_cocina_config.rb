# frozen_string_literal: true

load_config_file(File.expand_path(Rails.root.join('lib/traject/dor_base_config.rb').to_s))

# TODO: For Cocina, instead of storing the JSON as we do for the MODS XML, we will
# fetch the Cocina JSON from the PURL service and use it directly on demand.
# to_field 'modsxml', (accumulate { |resource, *_| resource.smods_rec.to_xml })

# title fields
to_field 'title_245a_search', cocina_display(:short_title)
to_field 'title_245_search', cocina_display(:full_title)
to_field 'title_variant_search', cocina_display(:additional_titles) do |_record, accumulator|
  accumulator.reject!(&:blank?)
end
to_field 'title_sort', cocina_display(:sort_title)
to_field 'title_245a_display', cocina_display(:short_title)
to_field 'title_display', cocina_display(:display_title)

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
# TODO: Why do we have these two fields with different names with the same values?
to_field 'author_person_display', cocina_display(:person_contributor_names, with_date: true)
to_field 'author_person_full_display', cocina_display(:person_contributor_names, with_date: true)

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
to_field 'physical', cocina_display_path('$.description.form[?match(@.type, "extent")].value')

to_field 'summary_search', cocina_display_path('$.description.note[?match(@.type, "abstract")].value')
to_field 'toc_search', cocina_display_path('$.description.note[?match(@.type, "table of contents")].value')
to_field 'url_suppl', cocina_display_path('$.description.relatedResource.*.access.url.*.value')
to_field 'url_suppl', cocina_display_path('$.description.relatedResource.*..purl')
to_field 'url_suppl', (accumulate do |resource, *_|
  resource.cocina_record.path('$.structural.isMemberOf.*').to_a.map do |v|
    "https://purl.stanford.edu/#{v.delete_prefix('druid:')}"
  end
end)

# publication fields
# Based on schema.xml, pub_search is also copied over to pub_display
# TODO: should `production` events be considered publication events?
to_field 'pub_search', cocina_display(:publication_places)
to_field 'pub_year_isi', cocina_display(:pub_year_int, ignore_qualified: false) # for sorting
# these are for single value facet display (in lieu of date slider (pub_year_tisim) )
to_field 'pub_year_no_approx_isi', cocina_display(:pub_year_int, ignore_qualified: true)
to_field 'pub_year_w_approx_isi', cocina_display(:pub_year_int, ignore_qualified: false)

to_field 'pub_year_tisim', cocina_display(:pub_year_int_range)

to_field 'date_ssim', (accumulate do |resource, *_|
  resource.cocina_record.event_dates.map(&:qualified_value)
end)

to_field 'imprint_display', cocina_display(:imprint_str)

to_field 'publisher_ssim', cocina_display(:publisher_names)
to_field 'publisher_tesim', cocina_display(:publisher_names)
to_field 'publisher_ssi' do |_resource, accumulator, context|
  value = Array(context.output_hash['publisher_tesim']).first
  accumulator << value if value
end

# equivalent to modsxml_tsi; *_tsi fields get copied to all_search and all_unstem_search
to_field 'cocina_description_tsi', cocina_display(:text)

to_field 'author_no_collector_ssim' do |resource, accumulator|
  authors_without_collectors = resource.cocina_record.contributors.select(&:person?).reject do |c|
    c.roles.map(&:to_s).all?('collector')
  end

  accumulator.concat(authors_without_collectors.map { |c| c.display_name(with_date: true) })
end

to_field 'box_ssi', (accumulate { |resource, *_| resource.cocina_physical_location.box })

to_field 'collector_ssim' do |resource, accumulator|
  collectors = resource.cocina_record.contributors.select(&:person?).select do |c|
    c.roles.map(&:to_s).any?('collector')
  end

  accumulator.concat(collectors.map { |c| c.display_name(with_date: true) })
end

to_field 'folder_ssi', (accumulate { |resource, *_| resource.cocina_physical_location.folder })
to_field 'genre_ssim', cocina_display_path('$.description.form[?match(@.type, "genre")].value')
to_field 'genre_ssim', cocina_display_path('$.description.subject[?match(@.type, "genre")].value')
to_field 'location_ssi', (accumulate { |resource, *_| resource.cocina_physical_location.physical_location_str })
to_field 'series_ssi', (accumulate { |resource, *_| resource.cocina_physical_location.series })
to_field 'identifier_ssim', cocina_display_path('$.description.identifier..[?(@.value)].value')

to_field 'coordinates_tesim', cocina_display(:coordinates)
to_field 'geographic_srpt', cocina_display(:coordinates_as_wkt)
to_field 'geographic_srpt', (accumulate { |resource, *_| resource.cocina_record.geonames_ids }) do |_resource, accumulator, _context|
  accumulator.map! do |id|
    get_geonames_api_envelope(id)
  end

  accumulator.compact!
end

# # FEIGENBAUM FIELDS

to_field 'doc_subtype_ssi', cocina_display_path('$.description.note[?(@.displayLabel == "Document subtype")].value')

to_field 'donor_tags_ssim', (accumulate do |resource, *_|
  resource.cocina_record.path('$.description.note[?(@.displayLabel == "Donor tags")].value').to_a.map do |v|
    v.sub(/^./, &:upcase)
  end
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

# # PARKER FIELDS

to_field 'manuscript_number_tesim',
         cocina_display_path('$.description..access.physicalLocation[?(@.type == "shelf locator")].value')

to_field 'incipit_tesim', cocina_display_path('$.description..note[?(@.type == "incipit")].value')

to_field 'dimensions_ssim' do |resource, accumulator, _context|
  resource.cocina_record.path('$.description..note[?(@.type == "dimensions")]').each do |dimension|
    accumulator << [dimension['value'], dimension['displayLabel']].join(' ')
  end
end

to_field 'provenance_ssim' do |resource, accumulator, _context|
  resource.cocina_record.path('$.description..note[?(@.type == "provenance")]').each do |provenance|
    accumulator << provenance['value']
  end
end

to_field 'identifier_displayLabel_ssim' do |resource, accumulator, _context|
  resource.cocina_record.path('$.description.identifier.*').each do |identifier|
    accumulator << "#{identifier['displayLabel'] || identifier['type']}-|-#{identifier['value']}"
  end

  accumulator.sort!
end

to_field 'repository_ssim', (accumulate do |resource, _context|
  resource.cocina_record.path('$.description.access.accessContact[?(@.type == "repository")].value').to_a
end)

to_field 'place_created_ssim', cocina_display(:publication_places)
