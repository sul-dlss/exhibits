module Spotlight::Resources
  class Purl < Spotlight::Resources::DorResource
    self.weight = -1000

    def self.can_provide? res
      !!(res.url =~ /^https?:\/\/purl.stanford.edu/)
    end

    def doc_id
      url.match(/^https?:\/\/purl.stanford.edu\/([^#\/\.]+)/)[1]
    end

  end
end
