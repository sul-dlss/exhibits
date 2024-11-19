require 'oembed'

OEmbed::Providers.register_all

# embeds all route through purl to start. 
# purl.stanford.edu/embed redirects to embed.stanford.edu
purl_provider = OEmbed::Provider.new('http://localhost:3001/embed.{format}?&hide_title=true')
# purl_provider = OEmbed::Provider.new('http://purl.stanford.edu/embed.{format}?&hide_title=true')
purl_provider << 'http://purl.stanford.edu/*'
purl_provider << 'https://purl.stanford.edu/*'
purl_provider << 'http://searchworks.stanford.edu/*'

purl_uat_provider = OEmbed::Provider.new('https://sul-purl-uat.stanford.edu/embed.{format}?&hide_title=true')
purl_uat_provider << 'http://sul-purl-uat.stanford.edu/*'
purl_uat_provider << 'https://sul-purl-uat.stanford.edu/*'

OEmbed::Providers.register(purl_provider)
OEmbed::Providers.register(purl_uat_provider)
