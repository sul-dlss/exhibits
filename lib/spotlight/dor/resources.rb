require "harvestdor-indexer"
require "spotlight/dor/resources/version"

module Spotlight
  module Dor
    module Resources

      require "spotlight/dor/indexer"
      require "spotlight/dor/resources/engine"
      
      def self.indexer
        @indexer ||= Spotlight::Dor::Indexer.new File.join(Rails.root, "config", "gdor.yml"), solr: Blacklight.solr_config
      end
    end
  end
end
