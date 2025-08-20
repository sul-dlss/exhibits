# frozen_string_literal: true
ActiveSupport::Reloader.to_prepare do
  Riiif::Image.file_resolver = Spotlight::CarrierwaveFileResolver.new

  # Riiif::Image.authorization_service = IIIFAuthorizationService

  # Riiif.not_found_image = 'app/assets/images/us_404.svg'
  #
  Riiif::Engine.config.cache_duration = 365.days

  # ImageMagick 7 commands are prefixed with "magick". This is needed until
  # we update the default commands set by the Riiif gem.
  Riiif::ImagemagickCommandFactory.external_command = "magick convert"
  Riiif::ImageMagickInfoExtractor.external_command  = "magick identify"
end
