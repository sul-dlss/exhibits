require "harvestdor-indexer"
require "spotlight/dor/resources/version"

module Spotlight
  module Dor
    module Resources

      class << self
        attr_accessor :indexer
      end

      require "spotlight/dor/indexer"
      require "spotlight/dor/resources/engine"

    end
  end
end
