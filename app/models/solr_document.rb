# frozen_string_literal: true

# :nodoc:
class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightHeatmaps::GeometrySolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  include Spotlight::SolrDocument

  include Spotlight::SolrDocument::AtomicUpdates

  include BibliographyConcern

  include ManifestConcern
  include MetadataConcern
  include CanvasConcern
  include ModsDisplay::ModelExtension

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
  use_extension(ModsDocument) do |document|
    document[:modsxml]
  end

  mods_xml_source do |model|
    model.fetch(:modsxml)
  end

  def full_text_highlights
    highlighting_response = response.dig('highlighting', id) || {}

    all_results = highlighting_response.select do |k, _|
      Settings.full_text_highlight.fields.include?(k)
    end.values.flatten.compact

    all_results.uniq do |value|
      value.gsub(%r{</?em>}, '')
    end
  end

  def full_text?
    self['has_full_text_func_boolean']
  end

  def external_iiif?
    self[self.class.resource_type_field].present? &&
      self[self.class.resource_type_field].include?('spotlight/resources/iiif_harvesters')
  end
end
