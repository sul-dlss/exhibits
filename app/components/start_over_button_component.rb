# frozen_string_literal: true

# Overrides the default Blacklight StartOverButtonComponent in order to
# always set the start_over_path the root path of the site/exhibit being searched
class StartOverButtonComponent < Blacklight::StartOverButtonComponent
  private

  def start_over_path(_query_params = params)
    params[:exhibit_id] ? helpers.exhibit_root_path(params[:exhibit_id]) : root_path
  end
end
