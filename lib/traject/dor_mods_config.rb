# frozen_string_literal: true

load_config_file(File.expand_path(Rails.root.join('lib/traject/dor_base_config.rb').to_s))

to_field 'modsxml', (accumulate { |resource, *_| resource.smods_rec.to_xml })

# title fields
to_field 'title_245a_search', stanford_mods(:sw_short_title)
to_field 'title_245_search', stanford_mods(:sw_full_title)
to_field 'title_variant_search', stanford_mods(:sw_addl_titles) do |_record, accumulator|
  accumulator.reject!(&:blank?)
end
to_field 'title_sort', stanford_mods(:sw_sort_title)
to_field 'title_245a_display', stanford_mods(:sw_short_title)
to_field 'title_display', stanford_mods(:sw_title_display)

# author fields
to_field 'author_1xx_search', stanford_mods(:sw_main_author)
to_field 'author_7xx_search', stanford_mods(:sw_addl_authors)
to_field 'author_person_facet', stanford_mods(:sw_person_authors)
to_field 'author_other_facet', stanford_mods(:sw_impersonal_authors)
to_field 'author_sort', stanford_mods(:sw_sort_author) do |_record, accumulator|
  accumulator.map! { |v| v.tr("\uFFFF", "\uFFFD") }
end

to_field 'author_corp_display', stanford_mods(:sw_corporate_authors)
to_field 'author_meeting_display', stanford_mods(:sw_meeting_authors)
# TODO: Why do we have these two fields with different names with the same values?
to_field 'author_person_display', stanford_mods(:sw_person_authors)
to_field 'author_person_full_display', stanford_mods(:sw_person_authors)

to_field 'name_ssim' do |resource, accumulator|
  resource.display_names_with_roles.each do |name_and_role|
    accumulator << name_and_role[:name]
  end
end

to_field 'name_roles_ssim' do |resource, accumulator|
  resource.display_names_with_roles.each do |name_and_role|
    if name_and_role[:roles].any?
      name_and_role[:roles].each do |role|
        accumulator << "#{role}|#{name_and_role[:name]}"
      end
    else
      accumulator << "|#{name_and_role[:name]}"
    end
  end
end

# subject search fields
to_field 'topic_search', stanford_mods(:topic_search)
to_field 'geographic_search', stanford_mods(:geographic_search)
to_field 'subject_other_search', stanford_mods(:subject_other_search)
to_field 'subject_other_subvy_search', stanford_mods(:subject_other_subvy_search)
to_field 'subject_all_search', stanford_mods(:subject_all_search)
to_field 'topic_facet', stanford_mods(:topic_facet)
to_field 'geographic_facet', stanford_mods(:geographic_facet)
to_field 'era_facet', stanford_mods(:era_facet)

to_field 'format_main_ssim', conditional(->(resource, *_) { !resource.collection? }, stanford_mods(:format_main))

to_field 'language', stanford_mods(:sw_language_facet)
to_field 'physical', stanford_mods(:term_values, [:physical_description, :extent])
to_field 'summary_search', stanford_mods(:term_values, :abstract)
to_field 'toc_search', stanford_mods(:term_values, :tableOfContents)
to_field 'url_suppl', stanford_mods(:term_values, [:related_item, :location, :url])

# publication fields
# Based on schema.xml, pub_search is also copied over to pub_display
to_field 'pub_search', stanford_mods(:place)
to_field 'pub_year_isi', stanford_mods(:pub_year_int, ignore_approximate: false) # for sorting
# these are for single value facet display (in lieu of date slider (pub_year_tisim) )
to_field 'pub_year_no_approx_isi', stanford_mods(:pub_year_int, ignore_approximate: true)
to_field 'pub_year_w_approx_isi', stanford_mods(:pub_year_int, ignore_approximate: false)

to_field 'pub_year_tisim' do |resource, accumulator, _context|
  resource.smods_rec.origin_info.each do |element|
    date_elements = date_elements_from_origin_info(element)

    next if date_elements.nil? || date_elements.none?

    dates = dates_from_date_elements(date_elements)
    accumulator.concat dates.flatten
  end

  accumulator.uniq!
end

to_field 'date_ssim' do |resource, accumulator, _context|
  values = resource.smods_rec.origin_info
  imprint_display = ModsDisplay::HTML.new(resource.smods_rec).mods_field(:imprint)

  Array(values).each do |value|
    dates = imprint_display.date_values(value)
    accumulator.concat(dates.map(&:values).flatten)

    part = imprint_display.send(:parts_element, value)
    accumulator << part if part.present?
  end
end

to_field 'imprint_display', stanford_mods(:imprint_display_str)

to_field 'publisher_ssim', stanford_mods(:term_values, [:origin_info, :publisher])
to_field 'publisher_tesim', stanford_mods(:term_values, [:origin_info, :publisher])
to_field 'publisher_ssi' do |_resource, accumulator, context|
  value = Array(context.output_hash['publisher_tesim']).first
  accumulator << value if value
end

# equivalent to cocina_description_tsi; *_tsi fields get copied to all_search and all_unstem_search
to_field 'modsxml_tsi', (accumulate { |resource, *_| resource.smods_rec.text.gsub(/\s+/, ' ') })

to_field 'author_no_collector_ssim' do |resource, accumulator|
  non_collector_authors = resource.smods_rec.personal_name.select { |n| n.role.any? }.reject { |n| n.role.all? { |r| includes_marc_relator_role?(r, value: 'Collector', value_uri: 'http://id.loc.gov/vocabulary/relators/col') } }

  accumulator.concat(non_collector_authors.map(&:display_value_w_date))
end

to_field 'box_ssi', stanford_mods(:box)

# add coordinates solr field containing the cartographic coordinates per
# MODS subject.cartographics.coordinates (via stanford-mods gem)
to_field 'coordinates_tesim', stanford_mods(:coordinates)

to_field 'collector_ssim' do |resource, accumulator|
  collectors = resource.smods_rec.personal_name.select { |n| n.role.any? }.select { |n| n.role.any? { |r| includes_marc_relator_role?(r, value: 'Collector', value_uri: 'http://id.loc.gov/vocabulary/relators/col') } }

  accumulator.concat(collectors.map(&:display_value_w_date))
end
to_field 'folder_ssi', stanford_mods(:folder)
to_field 'genre_ssim', stanford_mods(:term_values, :genre)
to_field 'genre_ssim', stanford_mods(:term_values, [:subject, :genre])
to_field 'location_ssi', stanford_mods(:physical_location_str)
to_field 'series_ssi', stanford_mods(:series)
to_field 'identifier_ssim', (accumulate { |resource, *_| resource.smods_rec.identifier.content })

to_field 'geographic_srpt', (accumulate { |resource, *_| extract_geonames_ids(resource) }) do |_resource, accumulator, _context|
  accumulator.map! do |id|
    get_geonames_api_envelope(id)
  end

  accumulator.compact!
end

to_field 'geographic_srpt', stanford_mods(:coordinates_as_envelope)
to_field 'geographic_srpt', stanford_mods(:geo_extensions_as_envelope)
to_field 'geographic_srpt', stanford_mods(:geo_extensions_point_data)

# Validate ENVELOPE() data before solr rejects them as part of a batch
each_record do |_resource, context|
  next unless context.output_hash['geographic_srpt']

  bad_coordinates = context.output_hash['geographic_srpt'].select { |x| x.starts_with? 'ENVELOPE' }.reject do |envelope|
    coords = envelope.scan(/([-\d.]+)/).flatten.map(&:to_f)
    minx, maxx, maxy, miny = coords
    (minx <= maxx) || (miny <= maxy) || (-90..90).cover?(maxy) || (-90..90).cover?(miny) || (-180..180).cover?(minx) || (-180..180).cover?(maxx)
  end

  raise "Invalid envelope data: #{bad_coordinates.inspect}" if bad_coordinates.any?
end

# FEIGENBAUM FIELDS

to_field 'doc_subtype_ssi' do |resource, accumulator, _context|
  subtype = resource.smods_rec.note.select { |n| n.displayLabel == 'Document subtype' }.map(&:content)
  accumulator << subtype.first unless subtype.empty?
end

to_field 'donor_tags_ssim', (accumulate { |resource, *_| resource.smods_rec.note.select { |n| n.displayLabel == 'Donor tags' }.map(&:content) }) do |_resource, accumulator, _context|
  accumulator.map! { |v| v.sub(/^./, &:upcase) }
end

to_field 'folder_name_ssi' do |resource, accumulator, _context|
  preferred_citation = resource.smods_rec.note.select { |n| n.type_at == 'preferred citation' }.map(&:content)
  match_data = preferred_citation.first.match(/Title: +(.+)/i) if preferred_citation.present?
  accumulator << match_data[1].strip if match_data.present?
end

to_field 'general_notes_ssim', (accumulate { |resource, *_| resource.smods_rec.note.select { |n| n.type_at.blank? && n.displayLabel.blank? }.map(&:content) })

# PARKER FIELDS

to_field 'manuscript_number_tesim', (accumulate { |resource, *_| resource.smods_rec.location.shelfLocator&.text })

to_field 'incipit_tesim', (accumulate { |resource, *_| parse_incipit(resource) })

to_field 'dimensions_ssim' do |resource, accumulator, _context|
  resource.smods_rec.physical_description.note.select { |x| x.attr('type') == 'dimensions' }.each do |dimension|
    accumulator << [dimension.content, dimension.displayLabel].join(' ')
  end
end

to_field 'provenance_ssim' do |resource, accumulator, _context|
  resource.smods_rec.physical_description.note.select { |x| x.attr('type') == 'provenance' }.each do |provenance|
    accumulator << provenance.content
  end
end

to_field 'identifier_displayLabel_ssim' do |resource, accumulator, _context|
  resource.smods_rec.identifier.each do |identifier|
    accumulator << "#{identifier.displayLabel || identifier.type}-|-#{identifier.content}"
  end

  accumulator.sort!
end

to_field 'repository_ssim', (accumulate do |resource, _context|
  resource.smods_rec.location.physicalLocation.select { |x| x.attr('type') == 'repository' }.map(&:content)
end)

to_field 'place_created_ssim', (accumulate do |resource, _context|
  resource.smods_rec.origin_info.place.placeTerm.select { |x| x.attr('type') == 'text' }.map(&:content)
end)

def parse_incipit(sdb)
  sdb.smods_rec.related_item.each do |item|
    item.note.each do |note|
      return note.text.strip if note.attr('type') == 'incipit'
    end
  end
  nil
end

# @return [Array{String}] The IDs from geonames //subject/geographic URIs, if any
def extract_geonames_ids(sdb)
  sdb.smods_rec.subject.map do |z|
    next unless z.geographic.any?

    uri = z.geographic.attr('valueURI')
    next if uri.nil?

    m = %r{^https?://sws\.geonames\.org/(\d+)}i.match(uri.value)
    m ? m[1] : nil
  end.compact.reject(&:empty?)
end

# @param Nokogiri::XML::Node role_node the role node from a parent name node
# @return true if there is a MARC relator collector role assigned
def includes_marc_relator_role?(role_node, value:, value_uri: nil)
  (role_node.authority.include?('marcrelator') && role_node.value.include?(value)) ||
    (value_uri && role_node.roleTerm.valueURI.first == value_uri)
end

def date_elements_from_origin_info(origin_info)
  if origin_info.as_object.first.key_dates.any?
    origin_info.as_object.first.key_dates.map(&:as_object).flatten
  else
    [:dateIssued, :dateCreated, :dateCaptured, :copyrightDate].map do |date_field|
      next unless origin_info.respond_to?(date_field)

      date_elements = origin_info.send(date_field)
      date_elements.map(&:as_object).flatten if date_elements.any?
    end.compact.first
  end
end

def dates_from_date_elements(date_elements) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  if date_elements.find(&:start?)&.as_range && date_elements.find(&:end?)&.as_range
    start_date = date_elements.find(&:start?)
    end_date = date_elements.find(&:end?)

    (start_date.as_range.min.year..end_date.as_range.max.year).to_a
  elsif date_elements.find(&:start?)&.as_range
    start_date = date_elements.find(&:start?)

    (start_date.as_range.min.year..Time.zone.now.year).to_a
  elsif date_elements.one?
    date_elements.first.to_a.map(&:year)
  else
    date_elements.map { |v| v.to_a.map(&:year) }
  end
end
