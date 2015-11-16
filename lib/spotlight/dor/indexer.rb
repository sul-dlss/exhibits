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

    concerning :RawMods do
      included do
        before_index :add_genre
      end

      # add plain MODS <genre> element data, not the SearchWorks genre values
      def add_genre(sdb, solr_doc)
        insert_field solr_doc, 'genre', sdb.smods_rec.genre.content, :symbol # this is a _ssim field
      end
    end

    concerning :PhysicalLocation do
      included do
        before_index :add_box
        before_index :add_folder
        before_index :add_location
        before_index :add_series
      end

      # add the box number to solr_doc as box_ssi field (note: single valued!)
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      # TODO:  push this up to stanford-mods gem?  or should it be hierarchical series/box/folder?
      def add_box(sdb, solr_doc)
        # see spec for data from actual collections
        #   _location.physicalLocation should find top level and relatedItem
        box_num = sdb.smods_rec._location.physicalLocation.map do |node|
          val = node.text
          # note that this will also find Flatbox or Flat-box
          match_data = val.match(/Box ?:? ?([^,|(Folder)]+)/i)
          match_data[1].strip if match_data.present?
        end.compact

        solr_doc['box_ssi'] = box_num.first
      end

      # add the folder number to solr_doc as folder_ssi field (note: single valued!)
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      # TODO:  push this up to stanford-mods gem?  or should it be hierarchical series/box/folder?
      def add_folder(sdb, solr_doc)
        # see spec for data from actual collections
        #   _location.physicalLocation should find top level and relatedItem
        folder_num = sdb.smods_rec._location.physicalLocation.map do |node|
          val = node.text

          match_data = if val =~ /\|/
                         # we assume the data is pipe-delimited, and may contain commas within values
                         val.match(/Folder ?:? ?([^|]+)/)
                       else
                         # the data should be comma-delimited, and may not contain commas within values
                         val.match(/Folder ?:? ?([^,]+)/)
                       end

          match_data[1].strip if match_data.present?
        end.compact

        solr_doc['folder_ssi'] = folder_num.first
      end

      # add the physicalLocation as location_ssi field (note: single valued!)
      #   but only if it has series, box or folder data
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      # TODO:  push this up to stanford-mods gem?  or should it be hierarchical series/box/folder?
      def add_location(sdb, solr_doc)
        # see spec for data from actual collections
        #   _location.physicalLocation should find top level and relatedItem
        loc = sdb.smods_rec._location.physicalLocation.map do |node|
          node.text if node.text.match(/.*(Series)|(Accession)|(Folder)|(Box).*/i)
        end.compact

        solr_doc['location_ssi'] = loc.first
      end

      # add the series/accession 'number' to solr_doc as series_ssi field (note: single valued!)
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      # TODO:  push this up to stanford-mods gem?  or should it be hierarchical series/box/folder?
      def add_series(sdb, solr_doc)
        # see spec for data from actual collections
        #   _location.physicalLocation should find top level and relatedItem
        series_num = sdb.smods_rec._location.physicalLocation.map do |node|
          val = node.text
          # feigenbaum uses 'Accession'
          match_data = val.match(/(?:(?:Series)|(?:Accession)):? ([^,|]+)/i)
          match_data[1].strip if match_data.present?
        end.compact

        solr_doc['series_ssi'] = series_num.first
      end
    end

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
        before_index :add_donor_tags
        before_index :add_folder_name
      end

      def add_donor_tags(sdb, solr_doc)
        donor_tags = sdb.smods_rec.note.select { |n| n.displayLabel == 'Donor tags' }.map(&:content)
        insert_field solr_doc, 'donor_tags', donor_tags, :symbol # this is a _ssim field
      end

      # add the folder name to solr_doc as folder_name_ssi field (note: single valued!)
      #   data is specific to Feigenbaum collection and is in <note type='preferred citation'>
      def add_folder_name(sdb, solr_doc)
        # see spec for data examples
        preferred_citation = sdb.smods_rec.note.select { |n| n.type_at == 'preferred citation' }.map(&:content)
        match_data = preferred_citation.first.match(/Title: +(.+)/i) if preferred_citation.present?
        solr_doc['folder_name_ssi'] = match_data[1].strip if match_data.present?
      end
    end

    concerning :FullTextIndexing do
      included do
        before_index :add_object_full_text
      end

      # search for configured full text files, and if found, add them to the full text (whole document) solr field
      def add_object_full_text(sdb, solr_doc)
        full_text_urls = object_level_full_text_urls(sdb)
        return if full_text_urls.size == 0
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

    concerning :CartographicIndexing do
      included do
        before_index :mods_cartographics_indexing
      end

      def mods_cartographics_indexing(sdb, solr_doc)
        coordinates = Array(sdb.smods_rec.subject.cartographics.coordinates)

        insert_field(solr_doc, 'coordinates', coordinates.map(&:text), :stored_searchable)

        solr_doc['point_bbox'] ||= []
        solr_doc['point_bbox'] += coords_to_bboxes(coordinates)
      end

      private

      def coords_to_bboxes(coordinates)
        coordinates.select { |n| n.text =~ /^\(.*\)$/ }.map do |n|
          coord_to_bbox(n.text)
        end
      end

      def coord_to_bbox(coord)
        bbox = coord.delete('(').delete(')')

        lng, lat = bbox.split('/')

        min_x, max_x = lng.split('--').map { |x| coord_to_decimal(x) }
        max_y, min_y = lat.split('--').map { |y| coord_to_decimal(y) }
        "#{min_x} #{min_y} #{max_x} #{max_y}"
      end

      def coord_to_decimal(point)
        regex = /(?<dir>[NESW])\s*(?<deg>\d+)°(?:(?<sec>\d+)ʹ)?/
        match = regex.match(point)
        dec = 0

        dec += match['deg'].to_i
        dec += match['sec'].to_f / 60
        dec = -1 * dec if match['dir'] == 'W' || match['dir'] == 'S'

        dec
      end
    end

    def insert_field(solr_doc, field, values, *args)
      Array(values).each do |v|
        Solrizer.insert_field solr_doc, field, v, *args
      end
    end
  end
end
