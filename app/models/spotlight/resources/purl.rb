module Spotlight::Resources
  # Resource provider for PURL pages
  class Purl < Spotlight::Resources::DorResource
    self.weight = -1000

    def self.can_provide?(res)
      res.url.match(%r{^https?://purl.stanford.edu/}).present?
    end

    def doc_id
      url.match(%r{^https?://purl.stanford.edu/([^#/\.]+)})[1]
    end
  end
end
