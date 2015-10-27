# external gems
require 'gdor/indexer'
require 'solrizer'
# Base class to harvest from DOR via harvestdor gem
module Spotlight::Dor
  class Indexer < GDor::Indexer
    # add contentMetadata fields
    before_index do |sdb, solr_doc|
      Solrizer.insert_field(solr_doc, 'content_metadata_type', sdb.public_xml.xpath("/publicObject/contentMetadata/@type").text, :symbol, :displayable)

      sdb.public_xml.xpath("/publicObject/contentMetadata").xpath('resource/file[@mimetype="image/jp2"]').each do |node|
        file_id = node.attr('id').gsub(".jp2", '')

        if node.attr('id') =~ /jp2$/ and !solr_doc[Solrizer.solr_name('content_metadata_first_image_file_name', :displayable)]
          Solrizer.insert_field(solr_doc, 'content_metadata_first_image_file_name', file_id, :displayable)
          Solrizer.insert_field(solr_doc, 'content_metadata_first_image_width', node.xpath('./imageData/@width').text, :displayable)
          Solrizer.insert_field(solr_doc, 'content_metadata_first_image_height', node.xpath('./imageData/@height').text, :displayable)
        end

        Solrizer.insert_field(solr_doc, 'content_metadata_image_iiif_info', "https://stacks.stanford.edu/image/iiif/#{solr_doc[:id]}%2F#{file_id}/info.json", :displayable)
        Solrizer.insert_field(solr_doc, 'thumbnail_square_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{file_id}_square", :displayable)
        Solrizer.insert_field(solr_doc, 'thumbnail_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{file_id}_thumb", :displayable)
        Solrizer.insert_field(solr_doc, 'large_image_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{file_id}_large", :displayable)
        Solrizer.insert_field(solr_doc, 'full_image_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{file_id}_full", :displayable)
      end
    end

    # tweak author_sort field from stanford-mods
    before_index do |_sdb, solr_doc|
      solr_doc[:author_sort] &&= solr_doc[:author_sort].gsub("\uFFFF", "\uFFFD")
    end

    # add fields from raw mods
    # see comment with add_donor_tags about Feigenbaum specific donor tags data
    before_index :add_box
    before_index :add_donor_tags
    before_index :add_genre
    before_index :add_folder
    before_index :add_series
    before_index :mods_cartographics_indexing

    def solr_client
      @solr_client
    end

    def solr_document resource
      doc_hash = super
      run_hook :before_index, resource, doc_hash
      doc_hash
    end

    def resource druid
      Harvestdor::Indexer::Resource.new harvestdor, druid
    end

    private

    # add the box number to solr_doc as box_ssim
    #   in some cases this information is in location/physicalLocation and
    #   in other cases it is in relatedItem/location/physicalLocation
    # TODO:  push this up to stanford-mods gem?  or should it be hierarchical series/box/folder?
    def add_box(sdb, solr_doc)
      # see spec for data from actual collections
      #   _location.physicalLocation should find both
      box_num = sdb.smods_rec._location.physicalLocation.map do |node|
        val = node.text
        # note that this will also find Flatbox or Flat-box
        match_data = val.match(/Box ?:? ?([^,|]+)/i)
        next if match_data.blank?
        result = match_data[1].rstrip
        match2_data = result.match(/(.*)Folder.*/i)
        if match2_data
          match2_data[1].rstrip
        else
          result
        end
      end
      insert_field solr_doc, 'box', box_num.uniq, :symbol # this is a _ssim field
    end

    # This new donor_tags_sim field was added in October 2015 specifically for the Feigenbaum exhibit.  It is very likely
    #  it will go ununsed by other projects, but should be benign (since this field will not be created if this specific MODs note is not found.)
    #  Later refactoring could include project specific fields.   Peter Mangiafico
    def add_donor_tags sdb, solr_doc
      donor_tags = sdb.smods_rec.note.select { |n| n.displayLabel == 'Donor tags' }.map(&:content)
      insert_field solr_doc, 'donor_tags', donor_tags, :symbol # this is a _ssim field
    end

    # add the folder number to solr_doc as folders_ssim
    # TODO:  push this up to stanford-mods gem?  or should it be hierarchical series/box/folder?
    def add_folder(sdb, solr_doc)
      # for feigenbaum collection, raw data is like this in location/physicalLocation
      # Call Number: SC0340, Accession 2005-101, Box : 42, Folder: 9
      # Call Number: SC0340, Accession 2005-101, Box: 42, Folder: 9
      # Call Number: SC0340, Accession: 2005-101, Box : 42, Folder: 20'
      # Call Number: SC0340, Accession: 1986-052, Box: 42, Folder: 1'
      folder_num = sdb.smods_rec.location.physicalLocation.map do |node|
        val = node.text
        res = val.match(/Folder:? ?([^,|]+)/i)
        res[1] unless res.nil?
      end
      insert_field solr_doc, 'folder', folder_num.uniq, :symbol # this is a _ssim field
    end

    # add plain MODS <genre> element data, not the SearchWorks genre values
    def add_genre sdb, solr_doc
      insert_field solr_doc, 'genre', sdb.smods_rec.genre.content, :symbol # this is a _ssim field
    end

    # add the series/accession 'number' to solr_doc as series_ssim field
    # TODO:  push this up to stanford-mods gem?  or should it be hierarchical series/box/folder?
    def add_series(sdb, solr_doc)
      # for feigenbaum collection, raw data is like this in location/physicalLocation
      # Call Number: SC0340, Accession 2005-101
      # Call Number: SC0340, Accession 2005-101, Box : 39, Folder: 9
      # Call Number: SC0340, Accession: 1986-052
      # Call Number: SC0340, Accession: 1986-052, Box : 50, Folder: 31
      # SC0340, Accession 1991-030
      series_num = sdb.smods_rec.location.physicalLocation.map do |node|
        val = node.text
        res = val.match(/Accession:? ([^,]+)/i)
        res[1] unless res.nil?
      end
      insert_field solr_doc, 'series', series_num.uniq, :symbol # this is a _ssim field
    end

    def mods_cartographics_indexing sdb, solr_doc
      insert_field(solr_doc, "coordinates", Array(sdb.smods_rec.subject.cartographics.coordinates).map { |n| n.text }, :stored_searchable)

      Array(sdb.smods_rec.subject.cartographics.coordinates).map do |n|
        next unless n.text =~ /^\(/ and n.text =~ /\)$/

        bbox = n.text.gsub(/[\(\)]/, '')

        lng, lat = bbox.split('/')

        minX,maxX = lng.split('--').map { |x| coord_to_decimal(x) }
        maxY,minY = lat.split('--').map { |x| coord_to_decimal(x) }

        solr_doc["point_bbox"] ||= []
        solr_doc["point_bbox"] << "#{minX} #{minY} #{maxX} #{maxY}"
      end
    end

    def coord_to_decimal point
      regex = /(?<dir>[NESW])\s*(?<deg>\d+)°(?:(?<sec>\d+)ʹ)?/
      match = regex.match(point)
      dec = 0

      dec += match['deg'].to_i
      dec += match['sec'].to_f / 60
      dec = -1 * dec if match['dir'] == "W" or match['dir'] == "S"

      dec
    end

    def insert_field solr_doc, field, values, *args
      Array(values).each do |v|
        Solrizer.insert_field solr_doc, field, v, *args
      end
    end
  end
end
