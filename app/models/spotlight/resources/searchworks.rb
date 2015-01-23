module Spotlight::Resources
  class Searchworks < Spotlight::Resources::DorResource

    self.weight = -1000

    def self.can_provide? res
      !!(res.url =~ /^https?:\/\/searchworks[^\.]*.stanford.edu/)
    end

    def doc_id
      url.match(/^https?:\/\/searchworks[^\.]*.stanford.edu\/.*view\/([^\/\.#]+)/)[1]
    end

  end
end
