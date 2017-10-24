# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

# external gems
require 'gdor/indexer'
require 'solrizer'
require 'faraday'
require 'nokogiri'

module Spotlight::Dor
  # Base class to harvest from DOR via harvestdor gem
  class Indexer < GDor::Indexer
    # Array-like object that dumps validation messages on the floor
    class DevNullValidationMessages < SimpleDelegator
      def concat(*args); end
    end

    def initialize(*args)
      super
      @validation_messages = DevNullValidationMessages.new([])
    end

    def resource(druid)
      Harvestdor::Indexer::Resource.new harvestdor, druid
    end

    def solr_document(resource)
      doc_hash = super
      run_hook :before_index, resource, doc_hash
      doc_hash
    end

    # tweak author_sort field from stanford-mods
    before_index do |_sdb, solr_doc|
      solr_doc[:author_sort] &&= solr_doc[:author_sort].tr("\uFFFF", "\uFFFD")
    end

    before_index :add_iiif_manifest_url

    # for Exhibits, we want to change collection formats to "Collection"
    before_index do |_sdb, solr_doc|
      if solr_doc[:collection_type] == 'Digital Collection'
        solr_doc[:format_main_ssim] = %w(Collection)
      end
    end

    private

    def add_iiif_manifest_url(sdb, solr_doc)
      # NOTE that the manifest URL may not work at runtime - so we need to check the contentMetadata type then
      solr_doc['iiif_manifest_url_ssi'] = iiif_manifest_url(sdb.bare_druid)
    end

    def iiif_manifest_url(bare_druid)
      format Settings.purl.iiif_manifest_url, druid: bare_druid
    end

    # Functionality grouped when code was moved to the StanfordMods gem
    concerning :StanfordMods do
      included do
        before_index :add_author_no_collector
        before_index :add_box
        before_index :add_collector
        before_index :add_coordinates
        before_index :add_folder
        before_index :add_genre
        before_index :add_geonames
        before_index :add_location
        before_index :add_geographic_srpt
        before_index :add_series
        before_index :add_identifiers
      end

      # add author_no_collector_ssim solr field containing the person authors, excluding collectors
      #   (via stanford-mods gem)
      def add_author_no_collector(sdb, solr_doc)
        insert_field solr_doc, 'author_no_collector', sdb.smods_rec.non_collector_person_authors, :symbol # _ssim field
      end

      def add_box(sdb, solr_doc)
        solr_doc['box_ssi'] = sdb.smods_rec.box
      end

      # pulls from //subject/geographic
      def add_geonames(sdb, solr_doc)
        ids = extract_geonames_ids(sdb)
        solr_doc['geographic_srpt'] ||= []
        solr_doc['geographic_srpt'] += ids.map { |id| get_geonames_api_envelope(id) }.compact
      end

      # add coordinates solr field containing the cartographic coordinates per
      # MODS subject.cartographics.coordinates (via stanford-mods gem)
      def add_coordinates(sdb, solr_doc)
        solr_doc['coordinates_tesim'] = sdb.smods_rec.coordinates
      end

      # add collector_ssim solr field containing the collector per MODS names (via stanford-mods gem)
      def add_collector(sdb, solr_doc)
        insert_field solr_doc, 'collector', sdb.smods_rec.collectors_w_dates, :symbol # _ssim field
      end

      def add_folder(sdb, solr_doc)
        solr_doc['folder_ssi'] = sdb.smods_rec.folder
      end

      # add plain MODS <genre> element data, not the SearchWorks genre values
      def add_genre(sdb, solr_doc)
        insert_field solr_doc, 'genre', sdb.smods_rec.genre.content, :symbol # this is a _ssim field
      end

      def add_location(sdb, solr_doc)
        solr_doc['location_ssi'] = sdb.smods_rec.physical_location_str
      end

      # add geographic_srpt solr field containing the point bounding box per
      # MODS subject.cartographics.coordinates (via stanford-mods gem)
      # and per stanford geo mods extension
      def add_geographic_srpt(sdb, solr_doc)
        solr_doc['geographic_srpt'] ||= []
        solr_doc['geographic_srpt'] += sdb.smods_rec.coordinates_as_envelope
        solr_doc['geographic_srpt'] += sdb.smods_rec.geo_extensions_as_envelope
        solr_doc['geographic_srpt'] += sdb.smods_rec.geo_extensions_point_data
      end

      def add_series(sdb, solr_doc)
        solr_doc['series_ssi'] = sdb.smods_rec.series
      end

      def add_identifiers(sdb, solr_doc)
        solr_doc['identifier_ssim'] = sdb.smods_rec.identifier.content
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

      # Fetch remote geonames metadata and format it for Solr
      # @param [String] id geonames identifier
      # @return [String] Solr WKT/CQL ENVELOPE based on //geoname/bbox
      def get_geonames_api_envelope(id)
        url = "http://api.geonames.org/get?geonameId=#{id}&username=#{Settings.geonames_username}"
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
    end # StanfordMods concern

    concerning :ContentMetadata do
      included do
        before_index :add_content_metadata_fields
      end

      def add_content_metadata_fields(sdb, solr_doc)
        content_metadata = sdb.public_xml.at_xpath('/publicObject/contentMetadata')
        return unless content_metadata.present?

        Solrizer.insert_field(solr_doc, 'content_metadata_type', content_metadata['type'], :symbol, :displayable)

        images = content_metadata.xpath('resource/file[@mimetype="image/jp2"]').select { |node| node.attr('id') =~ /jp2$/ }

        add_thumbnail_fields(images.first, solr_doc) if images.first

        images.each do |image|
          add_image_fields(image, solr_doc, sdb.bare_druid)
        end
      end

      def add_thumbnail_fields(node, solr_doc)
        file_id = node.attr('id').gsub('.jp2', '')
        image_data = node.at_xpath('./imageData')

        Solrizer.insert_field(solr_doc, 'content_metadata_first_image_file_name', file_id, :displayable)
        Solrizer.insert_field(solr_doc, 'content_metadata_first_image_width', image_data['width'], :displayable)
        Solrizer.insert_field(solr_doc, 'content_metadata_first_image_height', image_data['height'], :displayable)
      end

      def add_image_fields(node, solr_doc, bare_druid)
        file_id = node.attr('id').gsub('.jp2', '')
        base_url = stacks_iiif_url(bare_druid, file_id)

        Solrizer.insert_field(solr_doc, 'content_metadata_image_iiif_info', "#{base_url}/info.json", :displayable)
        Solrizer.insert_field(solr_doc, 'thumbnail_square_url', "#{base_url}/square/100,100/0/default.jpg", :displayable)
        Solrizer.insert_field(solr_doc, 'thumbnail_url', "#{base_url}/full/!400,400/0/default.jpg", :displayable)
        Solrizer.insert_field(solr_doc, 'large_image_url', "#{base_url}/full/!1000,1000/0/default.jpg", :displayable)
        Solrizer.insert_field(solr_doc, 'full_image_url', "#{base_url}/full/!3000,3000/0/default.jpg", :displayable)
      end

      def stacks_iiif_url(bare_druid, file_name)
        "#{Settings.stacks.iiif_url}/#{bare_druid}%2F#{file_name}"
      end
    end

    concerning :FeigenbaumSpecificFields do
      # These fields were specifically for the Feigenbaum exhibit.  It is very
      # likely it will go ununsed by other projects, but should be benign (since this field will not be created if
      # this specific MODs note is not found.). Future work could refactor this to
      # only create these fields on an as-needed basis.

      included do
        before_index :add_document_subtype
        before_index :add_donor_tags
        before_index :add_folder_name
        before_index :add_general_notes
      end

      def add_document_subtype(sdb, solr_doc)
        subtype = sdb.smods_rec.note.select { |n| n.displayLabel == 'Document subtype' }.map(&:content)
        solr_doc['doc_subtype_ssi'] = subtype.first unless subtype.empty?
      end

      # @note upcasing each word not the same as .capitalize (lowercases the rest of the string), or .titleize (breaks CamelCase words apart)
      def add_donor_tags(sdb, solr_doc)
        donor_tags = sdb.smods_rec.note.select { |n| n.displayLabel == 'Donor tags' }.map(&:content)
        insert_field solr_doc, 'donor_tags', donor_tags.map { |v| v.sub(/^./, &:upcase) }, :symbol # this is a _ssim field
      end

      # add the folder name to solr_doc as folder_name_ssi field (note: single valued!)
      #   data is specific to Feigenbaum collection and is in <note type='preferred citation'>
      def add_folder_name(sdb, solr_doc)
        # see spec for data examples
        preferred_citation = sdb.smods_rec.note.select { |n| n.type_at == 'preferred citation' }.map(&:content)
        match_data = preferred_citation.first.match(/Title: +(.+)/i) if preferred_citation.present?
        solr_doc['folder_name_ssi'] = match_data[1].strip if match_data.present?
      end

      def add_general_notes(sdb, solr_doc)
        general_notes = sdb.smods_rec.note.select { |n| n.type_at.blank? && n.displayLabel.blank? }.map(&:content)
        insert_field solr_doc, 'general_notes', general_notes, :symbol # this is a _ssim field
      end
    end # end feigbenbaum specific fields

    concerning :FullTextIndexing do
      included do
        before_index :add_object_full_text
      end

      # search for configured full text files, and if found, add them to the full text (whole document) solr field
      def add_object_full_text(sdb, solr_doc)
        full_text_urls = object_level_full_text_urls(sdb)
        return if full_text_urls.empty?
        solr_doc['full_text_tesimv'] = full_text_urls.map { |file_url| get_file_content(file_url) }.compact
      end

      # go grab the supplied file url, grab the file, encode and return
      # TODO: this should also be able to deal with .rtf and .xml files, scrubbing/converting as necessary to get plain text
      def get_file_content(file_url)
        response = Faraday.get(file_url)
        response.body.scrub.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').gsub(/\s+/, ' ')
      rescue
        logger.error("Error indexing full text - couldn't load file #{file_url}")
        nil
      end

      # these are the file locations where full txt files can be found at the object level
      # this method returns an array of fully qualified public URLs that can be accessed to find full text countent
      def object_level_full_text_urls(sdb)
        files = []
        object_level_full_text_filenames(sdb).each do |xpath_location|
          files += sdb.public_xml.xpath(xpath_location).map do |txt_file|
            "#{Settings.stacks.file_url}/#{sdb.bare_druid}/#{txt_file['id']}"
          end
        end
        files
      end

      # xpaths to locations in the contentMetadata where full text object level files can be found,
      #  add as many as you need, all will be searched
      def object_level_full_text_filenames(sdb)
        [
          "//contentMetadata/resource/file[@id=\"#{sdb.bare_druid}.txt\"]" # feigenbaum style - full text in .txt named for druid
        ]
      end
    end

    concerning :ParkerIndexing do
      included do
        before_index :add_manuscript_number
        before_index :add_manuscript_titles
        before_index :add_text_titles
        before_index :add_incipit
      end

      def add_manuscript_number(sdb, solr_doc)
        manuscript_number = sdb.smods_rec.location.shelfLocator.try(:text)
        return if manuscript_number.blank?
        insert_field solr_doc, 'manuscript_number', manuscript_number, :symbol
      end

      # We need to join the `displayLabel` and titles for all *alternative* titles
      # `title_variant_display` has different behavior
      def add_manuscript_titles(sdb, solr_doc)
        manuscript_titles = parse_manuscript_titles(sdb)
        return if manuscript_titles.blank?
        insert_field solr_doc, 'manuscript_titles', manuscript_titles, :symbol # this is a _ssim field
      end

      def add_text_titles(sdb, solr_doc)
        text_titles = sdb.smods_rec.tableOfContents.try(:content)
        return if text_titles.blank?
        insert_field solr_doc, 'text_titles', text_titles, :stored_searchable # this is a _tesim field
      end

      def add_incipit(sdb, solr_doc)
        incipit = parse_incipit(sdb)
        return if incipit.blank?
        insert_field solr_doc, 'incipit', incipit, :stored_searchable # this is a _tesim field
      end

      # parse titleInfo[type="alternative"]/title into tuples of (displayLabel, title)
      def parse_manuscript_titles(sdb)
        manuscript_titles = []
        sdb.smods_rec.title_info.each do |title_info|
          next unless title_info.attr('type') == 'alternative'
          display_label = title_info.attr('displayLabel')
          title_info.at_xpath('*[local-name()="title"]').tap do |title|
            label_with_title = [display_label, title.content].map(&:to_s).map(&:strip)
            manuscript_titles << label_with_title.join('-|-')
          end
        end
        manuscript_titles
      end
      private :parse_manuscript_titles

      def parse_incipit(sdb)
        sdb.smods_rec.related_item.each do |item|
          item.note.each do |note|
            return note.text.strip if note.attr('type') == 'incipit'
          end
        end
        nil
      end
      private :parse_incipit
    end

    def insert_field(solr_doc, field, values, *args)
      Array(values).each do |v|
        Solrizer.insert_field solr_doc, field, v, *args
      end
    end
  end
end
