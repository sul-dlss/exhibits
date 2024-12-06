# frozen_string_literal: true

module Blacklight
  # Display the creators/contributors by role facet in a tree hierarchy
  class NameRolesFacetHierarchyComponent < Blacklight::FacetFieldListComponent
    def facet_item_presenters
      facet_item_tree_hierarchy.map do |item|
        facet_item_presenter(item)
      end
    end

    def facet_items(wrapping_element: :li, **item_args)
      facet_item_component_class.with_collection(
        facet_item_presenters,
        wrapping_element:,
        suppress_link: true,
        **item_args
      )
    end

    # Solr data is in the form of role|name. Either can be empty.
    # E.g., ["Collector|", "Defendant|Becker, Friedrich", "|Wagner, Richard, 1813-1883"]
    def facet_item_tree_hierarchy(delimiter: facet_config.delimiter || '|')
      roles = {}

      @facet_field.paginator.items.each do |item|
        role, name = item.value.split(delimiter)
        next if role.blank? || name.blank?

        roles[role] ||= Blacklight::Solr::Response::Facets::FacetItem.new(
          value: role,
          hits: nil,
          items: []
        )
        roles[role].items << item if name.present?
      end

      roles.values
    end
  end
end
