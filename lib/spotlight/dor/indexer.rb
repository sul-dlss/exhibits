require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/object/try'
require 'solrizer'
require 'harvestdor-indexer'

module Spotlight::Dor
  class Indexer < Harvestdor::Indexer
    ##
    # Memoizing convenience wrapper around
    # indexer methods that retrieve object metadata.
    class Item
      attr_accessor :druid

      def initialize indexer, druid
        @indexer = indexer
        @druid = druid
        @data = {}
      end

      ##
      # Create memoizing equivalents for indexer
      # methods that collect data
      [:smods_rec,
        :public_xml,
        :content_metadata,
        :identity_metadata,
        :rights_metadata,
        :rdf].each do |method|
          define_method method do
            @data[method] ||= @indexer.send(method, druid)
          end

      end

      alias_method :mods, :smods_rec
    end

    ##
    # A list of methods to call to perform indexing, allowing
    # a subclass of the Metador indexer to override and customize
    # the indexing process
    class_attribute :indexing_logic

    # Default indexing steps.
    self.indexing_logic = [:default_mods_indexing, :content_metadata_indexing]

    def initialize config_file = nil
      config_file ||= default_config_path
      super(config_file)
    end

    def default_config_path
      File.join(Rails.root, "config", "harvestdor.yml")
    end

    def solr_document druid
      doc_hash = {}
      doc_hash[:id] = druid
      doc_hash[:druid_ssi] = druid

      item = Item.new self, druid

      indexing_logic.each do |step|
        send(step, item, doc_hash)
      end
      doc_hash
    end

    def index druid
      if blacklist.include?(druid)
        logger.info("Druid #{druid} is on the blacklist and will have no Solr doc created")
      else
        begin
          start_time=Time.now
          logger.info("About to index #{druid} at #{start_time}")
          #logger.debug "About to index #{druid}"
          doc_hash = solr_document(druid)
          solr_client.add(doc_hash)

          logger.info("Indexed #{druid} in #{elapsed_time(start_time)} seconds")
          @success_count+=1
          # TODO: provide call to code to update DOR object's workflow datastream??
        rescue => e
          @error_count+=1
          logger.error "Failed to index #{druid} in #{elapsed_time(start_time)} seconds: #{e.message}"
          raise e if raise_exception_on_error?
        end
      end
    end

    ##
    # By default, just perform some basic indexing
    def default_mods_indexing item, solr_doc
      Solrizer.insert_field(solr_doc, 'mods_xml', item.mods.to_xml, :displayable)
      mods_title_indexing item, solr_doc
      mods_name_indexing item, solr_doc
      mods_pubinfo_indexing item, solr_doc
      mods_cartographics_indexing item, solr_doc
      mods_notes_indexing item, solr_doc
      # mods_related_items_indexing item, solr_doc
      mods_subjects_indexing item, solr_doc
      mods_identifiers_indexing item, solr_doc
      # mods_location_indexing item, solr_doc
      # mods_part_indexing item, solr_doc

    end

    def content_metadata_indexing item, solr_doc
      Solrizer.insert_field(solr_doc, 'content_metadata_type', item.content_metadata.xpath('/contentMetadata/@type').text, :symbol, :displayable)

      item.content_metadata.xpath('//resource[@type="image"]/file/@id').each do |node|
        if node.text =~ /jp2$/ and !solr_doc[Solrizer.solr_name('content_metadata_first_image_file_name', :displayable)]
          Solrizer.insert_field(solr_doc, 'content_metadata_first_image_file_name', node.text.gsub(".jp2", ''), :displayable)
        end

        Solrizer.insert_field(solr_doc, 'content_metadata_image_file_name', node.text.gsub(".jp2", ''), :displayable)

        Solrizer.insert_field(solr_doc, 'thumbnail_square_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{node.text.gsub(".jp2", '')}_square", :displayable)
        Solrizer.insert_field(solr_doc, 'thumbnail_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{node.text.gsub(".jp2", '')}_thumb", :displayable)
        Solrizer.insert_field(solr_doc, 'large_image_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{node.text.gsub(".jp2", '')}_large", :displayable)
        Solrizer.insert_field(solr_doc, 'full_image_url', "https://stacks.stanford.edu/image/#{solr_doc[:id]}/#{node.text.gsub(".jp2", '')}_full", :displayable)

      end
    rescue Harvestdor::Errors::MissingContentMetadata
      nil
    end

    def mods_pubinfo_indexing item, solr_doc
      mods_language_indexing item, solr_doc
      mods_origininfo_indexing item, solr_doc
      mods_typeofresource_indexing item, solr_doc
      mods_genre_indexing item, solr_doc
      mods_physical_description_indexing item, solr_doc
    end

    def mods_title_indexing item, solr_doc
      insert_field(solr_doc, 'short_title', item.mods.short_titles, :stored_searchable)
      insert_field(solr_doc, 'full_title', item.mods.full_titles, :stored_searchable)
      insert_field(solr_doc, 'alternative_title', item.mods.alternative_titles, :stored_searchable)
      insert_field(solr_doc, 'sort_title', item.mods.sort_title, :stored_searchable, :stored_sortable)
    end

    def mods_name_indexing item, solr_doc
      insert_field(solr_doc, 'personal_name', item.mods.personal_names, :symbol, :stored_searchable, :displayable)
      insert_field(solr_doc, 'corporate_name', item.mods.corporate_names, :symbol, :stored_searchable, :displayable)
      insert_field(solr_doc, 'plain_name_roles', item.mods.plain_name.role.code, :symbol)

      item.mods.plain_name.each do |name|
        name.role.code.map { |n| n.to_s }.each do |code|
          insert_field(solr_doc, "plain_name_#{code}", name.namePart.map {|n| n.text }, :symbol,  :stored_searchable, :displayable)
        end
      end

    end

    def mods_language_indexing item, solr_doc
      insert_field(solr_doc, 'language', item.mods.languages, :symbol,  :stored_searchable, :displayable)
    end

    def mods_origininfo_indexing item, solr_doc
      insert_field(solr_doc, 'origin_publisher', item.mods.origin_info.publisher, :stored_searchable, :displayable)
      insert_field(solr_doc, 'origin_place_term', Array(item.mods.origin_info.place.placeTerm).map {|n| n.text }, :symbol,  :stored_searchable, :displayable)
      insert_field(solr_doc, 'origin_date_created', Array(item.mods.origin_info.dateCreated).map {|n| n.text }, :symbol,  :stored_searchable, :displayable)
    end

    def mods_typeofresource_indexing item, solr_doc
      insert_field(solr_doc, 'type_of_resource', item.mods.typeOfResource.text, :symbol, :displayable)
    end

    def mods_genre_indexing item, solr_doc
      insert_field(solr_doc, 'genre', Array(item.mods.genre).map {|n| n.text }, :symbol, :stored_searchable)
    end

    def mods_physical_description_indexing item, solr_doc
      insert_field(solr_doc, 'physical_description_form', (item.mods.try(:physical_description, :form) || []).map {|n| n.text }, :symbol, :stored_searchable, :displayable)
      insert_field(solr_doc, 'physical_description_extent', (item.mods.try(:physical_description, :extent) || []).map {|n| n.text }, :stored_searchable, :displayable)

      item.mods.physical_description.note.each do |note|
        insert_field(solr_doc, "physical_description_note_#{note.displayLabel}", note.text, :stored_searchable, :displayable)
      end
    end

    def mods_notes_indexing item, solr_doc
      insert_field(solr_doc, "abstract", Array(item.mods.abstract).map { |n| n.text }, :stored_searchable)
      insert_field(solr_doc, "table_of_contents", Array(item.mods.tableOfContents).map { |n| n.text }, :stored_searchable)
      insert_field(solr_doc, "target_audience", Array(item.mods.targetAudience).map { |n| n.text }, :stored_searchable)
      item.mods.note.each do |note|
        insert_field(solr_doc, "note_#{note.displayLabel}", note.text, :stored_searchable)
      end
      insert_field(solr_doc, "access_condition", Array(item.mods.accessCondition).map { |n| n.text }, :stored_searchable)
    end

    def mods_subjects_indexing item, solr_doc
      Mods::Subject::CHILD_ELEMENTS.each do |e|
        e = "#{e}_el" if e == 'name'
        item.mods.subject.send(e).each do |subject|
          insert_field(solr_doc, "subject_#{e}", subject.text, :symbol, :stored_searchable)
        end
      end
    end

    def mods_identifiers_indexing item, solr_doc
      insert_field(solr_doc, "identifier", Array(item.mods.identifier).map { |n| n.text }, :stored_searchable)
      item.mods.identifier.each do |id|
        insert_field(solr_doc, "identifier_#{id.type_at}_#{id.displayLabel}", id.text, :stored_searchable)
      end
    end

    def mods_cartographics_indexing item, solr_doc
      insert_field(solr_doc, "coordinates", Array(item.mods.subject.cartographics.coordinates).map { |n| n.text }, :stored_searchable)

    end

    def raise_exception_on_error?
      true
    end

    def insert_field solr_doc, field, values, *args
      Array(values).each do |v|
        Solrizer.insert_field solr_doc, field, v, *args
      end
    end
  end
end
