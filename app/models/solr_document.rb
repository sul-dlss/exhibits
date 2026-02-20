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
  include CanvasConcern

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
  use_extension(ModsDocument) do |document|
    document[:druid]
  end

  # document was harvested via dor_harvesters from Purl/SDR
  def dor_resource_type?
    self['spotlight_resource_type_ssim']&.include?('dor_harvesters')
  end

  def full_text_highlights
    highlighting_response = response.dig('highlighting', id) || {}

    all_results = highlighting_response.slice(*Settings.full_text_highlight.fields).values.flatten.compact

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
