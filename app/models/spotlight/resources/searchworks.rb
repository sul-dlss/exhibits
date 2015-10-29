module Spotlight::Resources
  # Resource provider for searchworks pages
  class Searchworks < Spotlight::Resources::DorResource
    self.weight = -1000

    def self.can_provide?(res)
      res.url.match(%r{^https?://searchworks[^\.]*.stanford.edu/}).present?
    end

    def doc_id
      url.match(%r{^https?://searchworks[^\.]*.stanford.edu/.*view/([^/\.#]+)})[1]
    end
  end
end
