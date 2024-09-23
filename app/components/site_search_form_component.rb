# frozen_string_literal: true

# Builds the site search form
class SiteSearchFormComponent < ViewComponent::Base
  def presenter
    Blacklight::SearchBarPresenter.new(controller, SearchAcrossController.blacklight_config)
  end

  def search_fields
    @search_fields ||= helpers.blacklight_config.search_fields.values
                              .select { |field_def| helpers.should_render_field?(field_def) }
                              .collect do |field_def|
      [helpers.label_for_search_field(field_def.key),
       field_def.key]
    end
  end
end
