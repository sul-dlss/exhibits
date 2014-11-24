require 'oembed'

OEmbed::Providers.register_all

purl_provider = OEmbed::Provider.new("http://purl.stanford.edu/embed")
purl_provider << "http://purl.stanford.edu/*"
purl_provider << "https://purl.stanford.edu/*"
purl_provider << "http://searchworks.stanford.edu/*"
OEmbed::Providers.register(purl_provider)