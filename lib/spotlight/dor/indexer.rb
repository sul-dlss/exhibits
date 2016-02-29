# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

# external gems
require 'gdor/indexer'
require 'solrizer'
require 'faraday'

module Spotlight::Dor
  # Base class to harvest from DOR via harvestdor gem
  class Indexer < GDor::Indexer
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

    private

    # Functionality grouped when code was moved to the StanfordMods gem
    concerning :StanfordMods do
      included do
        before_index :add_author_no_collector
        before_index :add_box
        before_index :add_collector
        before_index :add_coordinates
        before_index :add_folder
        before_index :add_genre
        before_index :add_location
        before_index :add_point_bbox
        before_index :add_series
      end

      # add author_no_collector_ssim solr field containing the person authors, excluding collectors
      #   (via stanford-mods gem)
      def add_author_no_collector(sdb, solr_doc)
        insert_field solr_doc, 'author_no_collector', sdb.smods_rec.non_collector_person_authors, :symbol # _ssim field
      end

      def add_box(sdb, solr_doc)
        solr_doc['box_ssi'] = sdb.smods_rec.box
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

      # add point_bbox solr field containing the point bounding box per
      # MODS subject.cartographics.coordinates (via stanford-mods gem)
      def add_point_bbox(sdb, solr_doc)
        solr_doc['point_bbox'] = sdb.smods_rec.coordinates_as_envelope
      end

      def add_series(sdb, solr_doc)
        solr_doc['series_ssi'] = sdb.smods_rec.series
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

      private

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
        Solrizer.insert_field(solr_doc, 'large_image_url', "#{base_url}/full/pct:25/0/default.jpg", :displayable)
        Solrizer.insert_field(solr_doc, 'full_image_url', "#{base_url}/full/full/0/default.jpg", :displayable)
      end

      def stacks_iiif_url(bare_druid, file_name)
        "#{Spotlight::Dor::Resources::Engine.config.stacks_iiif_url}/#{bare_druid}%2F#{file_name}"
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

      def add_donor_tags(sdb, solr_doc)
        donor_tags = sdb.smods_rec.note.select { |n| n.displayLabel == 'Donor tags' }.map(&:content)
        insert_field solr_doc, 'donor_tags', upcase_first_character(donor_tags), :symbol # this is a _ssim field
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
        solr_doc['full_text_tesimv'] = full_text_urls.map { |file_url| get_file_content(file_url) }
      end

      # go grab the supplied file url, grab the file, encode and return
      # TODO: this should also be able to deal with .rtf and .xml files, scrubbing/converting as necessary to get plain text
      def get_file_content(file_url)
        response = Faraday.get(file_url)
        response.body.scrub.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').gsub(/\s+/, ' ')
      rescue
        logger.warn("Error indexing full text - couldn't load file #{file_url}")
        nil
      end

      # these are the file locations where full txt files can be found at the object level
      # this method returns an array of fully qualified public URLs that can be accessed to find full text countent
      def object_level_full_text_urls(sdb)
        files = []
        object_level_full_text_filenames(sdb).each do |xpath_location|
          files += sdb.public_xml.xpath(xpath_location).map do |txt_file|
            "#{Spotlight::Dor::Resources::Engine.config.stacks_file_url}/#{sdb.bare_druid}/#{txt_file['id']}"
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

    # takes an array, upcases just the first character of each element in the array and returns the new array
    #   not the same as .captialize which will lowercase the rest of the string
    def upcase_first_character(values)
      values.map { |value| value.sub(/^./, &:upcase) }
    end

    def insert_field(solr_doc, field, values, *args)
      Array(values).each do |v|
        Solrizer.insert_field solr_doc, field, v, *args
      end
    end
  end
end
