Rails.application.config.to_prepare do
  Spotlight::FeaturedImage.validates :image, file_size: { less_than: 10.megabytes }
end
