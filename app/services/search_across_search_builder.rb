# frozen_string_literal: true

# Search builder for getting search results across exhibits
class SearchAcrossSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  DENY_ALL = 'id:does-not-exist'

  self.default_processor_chain += [:filter_public_documents_in_accessible_exhibits]

  def filter_public_documents_in_accessible_exhibits(solr_params)
    fq = Array.wrap(solr_params[:fq])

    if accessible_documents_query.blank?
      solr_params[:fq] = DENY_ALL
    else
      solr_params[:fq] = fq.append(accessible_documents_query) unless fq.include?(accessible_documents_query)
      solr_params[:"f.#{exhibit_slug_field}.facet.matches"] = Regexp.union(accessible_exhibit_slugs.map(&:slug))
    end

    solr_params
  end

  private

  def exhibit_slug_field
    SolrDocument.exhibit_slug_field
  end

  def accessible_exhibit_slugs
    @accessible_exhibit_slugs ||= Spotlight::Exhibit.accessible_by(current_ability).select(:id, :slug)
  end

  def accessible_documents_query
    accessible_exhibit_slugs.collect do |exhibit|
      filter = []
      filter << "#{exhibit_slug_field}:#{exhibit.slug}"
      unless current_ability&.can?(:curate, exhibit)
        filter << "#{blacklight_config.document_model.visibility_field(exhibit)}:true"
      end

      "(#{filter.join(' AND ')})"
    end.join(' OR ')
  end

  def current_ability
    (scope&.context || {})[:current_ability]
  end
end
