# frozen_string_literal: true

load_config_file(File.expand_path(Rails.root.join('lib/traject/dor_base_config.rb').to_s))

# TODO: cocina_json
# Without files? for rendering More Details in the UI like we do for MODS

# title fields
to_field 'title_245a_search', cocina_display(:main_title)
to_field 'title_245_search', cocina_display(:full_title)
to_field 'title_variant_search', cocina_display(:additional_titles) do |_record, accumulator|
  accumulator.reject!(&:blank?)
end
to_field 'title_sort', cocina_display(:sort_title)
to_field 'title_245a_display', cocina_display(:main_title)
to_field 'title_display', cocina_display(:display_title)

# author fields
to_field 'author_1xx_search', cocina_display(:main_author)
to_field 'author_7xx_search', cocina_display(:additional_authors)
to_field 'author_person_facet', cocina_display(:person_authors)
to_field 'author_other_facet', cocina_display(:impersonal_authors)
to_field 'author_sort', cocina_display(:sort_author) do |_record, accumulator|
  accumulator.map! { |v| v.tr("\uFFFF", "\uFFFD") } # TODO: this may not be right
end

to_field 'author_corp_display', cocina_display(:organization_authors)
to_field 'author_meeting_display', cocina_display(:conference_authors)
to_field 'author_person_display', cocina_display(:person_authors)
to_field 'author_person_full_display', cocina_display(:person_authors)

# subject search fields
to_field 'topic_search', cocina_display(:subject_topics)
# to_field 'geographic_search', stanford_mods(:geographic_search)
# to_field 'subject_other_search', stanford_mods(:subject_other_search)
# to_field 'subject_other_subvy_search', stanford_mods(:subject_other_subvy_search)
# to_field 'subject_all_search', stanford_mods(:subject_all_search)
# to_field 'topic_facet', stanford_mods(:topic_facet)
# to_field 'geographic_facet', stanford_mods(:geographic_facet)
# to_field 'era_facet', stanford_mods(:era_facet)

# to_field 'format_main_ssim', conditional(->(resource, *_) { !resource.collection? }, stanford_mods(:format_main))

# to_field 'language', cocina_display(:sw_language_facet)
to_field 'physical', cocina_display_path('$.description.form[?match(@.type, "extent")].value')

to_field 'summary_search', cocina_display_path('$.description.note[?match(@.type, "abstract")].value')
to_field 'toc_search', cocina_display_path('$.description.note[?match(@.type, "table of contents")].value')
# TODO: unclear what the cocina equivalent is
# to_field 'url_suppl', stanford_mods(:term_values, [:related_item, :location, :url])

# publication fields
# Based on schema.xml, pub_search is also copied over to pub_display
# to_field 'pub_search', stanford_mods(:place)
# to_field 'pub_year_isi', stanford_mods(:pub_year_int, ignore_approximate: false) # for sorting
# these are for single value facet display (in lieu of date slider (pub_year_tisim) )
# to_field 'pub_year_no_approx_isi', stanford_mods(:pub_year_int, ignore_approximate: true)
# to_field 'pub_year_w_approx_isi', stanford_mods(:pub_year_int, ignore_approximate: false)

to_field 'pub_year_tisim', cocina_display(:pub_year_int_range)

# to_field 'date_ssim' do |resource, accumulator, _context|
#   values = resource.smods_rec.origin_info

#   Array(values).each do |value|
#     dates = resource.imprint_display.date_values(value)
#     accumulator.concat(dates.map(&:values).flatten)

#     part = resource.imprint_display.send(:parts_element, value)
#     accumulator << part if part.present?
#   end
# end

to_field 'imprint_display', cocina_display(:imprint_display_str)

# TODO: Is there a way to get publisher info from cocina?
# to_field 'publisher_ssim', stanford_mods(:term_values, [:origin_info, :publisher])
# to_field 'publisher_tesim', stanford_mods(:term_values, [:origin_info, :publisher])
# to_field 'publisher_ssi' do |_resource, accumulator, context|
#   value = Array(context.output_hash['publisher_tesim']).first
#   accumulator << value if value
# end

# to_field 'modsxml_tsi', (accumulate { |resource, *_| resource.smods_rec.text.gsub(/\s+/, ' ') })

# to_field 'author_no_collector_ssim' do |resource, accumulator|
#   non_collector_authors = resource.smods_rec.personal_name.select { |n| n.role.any? }.reject { |n| n.role.all? { |r| includes_marc_relator_role?(r, value: 'Collector', value_uri: 'http://id.loc.gov/vocabulary/relators/col') } }

#   accumulator.concat(non_collector_authors.map(&:display_value_w_date))
# end

# to_field 'box_ssi', stanford_mods(:box)

# # add coordinates solr field containing the cartographic coordinates per
# # MODS subject.cartographics.coordinates (via stanford-mods gem)
# to_field 'coordinates_tesim', stanford_mods(:coordinates)

# to_field 'collector_ssim' do |resource, accumulator|
#   collectors = resource.smods_rec.personal_name.select { |n| n.role.any? }.reject { |n| n.role.any? { |r| includes_marc_relator_role?(r, value: 'Collector', value_uri: 'http://id.loc.gov/vocabulary/relators/col') } }

#   accumulator.concat(collectors.map(&:display_value_w_date))
# end
# to_field 'folder_ssi', stanford_mods(:folder)
to_field 'genre_ssim', cocina_display_path('$.description.form[?match(@.type, "genre")].value')
to_field 'genre_ssim', cocina_display_path('$.description.subject[?match(@.type, "genre")].value')
# to_field 'location_ssi', stanford_mods(:physical_location_str)
# to_field 'series_ssi', stanford_mods(:series)
# to_field 'identifier_ssim', (accumulate { |resource, *_| resource.smods_rec.identifier.content })
