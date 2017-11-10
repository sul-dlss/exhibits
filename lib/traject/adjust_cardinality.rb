# frozen_string_literal: true

module Traject
  # Given a data structure from traject, transform it into a valid IR by changing
  # some values from arrays to scalars
  class AdjustCardinality
    def self.call(attributes)
      new(attributes).call
    end

    def initialize(attributes)
      @source = attributes
    end

    attr_reader :source

    def call
      flatten_top_level(source)
    end

    def flatten_top_level(attributes)
      flatten = %w(
        id modsxml access_facet building_facet druid url_fulltext display_type collection_type
        author_1xx_search
        title_245_search title_245a_display title_245a_search title_display title_full_display title_sort
        all_search author_sort imprint_display
        creation_year_isi
        pub_date_sort
        pub_year_isi
        pub_year_no_approx_isi
        pub_year_tisim
        pub_year_w_approx_isi
        publication_year_isi
        folder_ssi box_ssi location_ssi series_ssi folder_name_ssi
        iiif_manifest_url_ssi
      )
      attributes.except(*flatten).tap do |output|
        flatten.each do |field|
          next unless attributes.key?(field)
          value = attributes.fetch(field).first
          output[field] = value
          output.delete(field) unless value.present?
        end
      end
    end
  end
end
