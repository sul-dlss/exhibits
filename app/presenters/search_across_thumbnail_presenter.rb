# frozen_string_literal: true

# Override the upstream presenter to suppress the thumbnail link behavior
class SearchAcrossThumbnailPresenter < Blacklight::ThumbnailPresenter
  def thumbnail_tag(image_options = {}, url_options = {})
    url_options[:suppress_link] = true
    super(image_options, url_options)
  end
end
