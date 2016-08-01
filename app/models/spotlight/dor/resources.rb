require 'harvestdor-indexer'

module Spotlight
  module Dor
    # Spotlight::Dor::Resources provides a Rails engine
    # that is capable of harvesting and indexing resources
    # from Searchworks and PURL endpoints
    module Resources
      class <<self
        def indexer
          @indexer ||= Spotlight::Dor::Indexer.new gdor_config_path, solr: solr_config
        end

        def gdor_config_path
          File.join(Rails.root, 'config', 'gdor.yml')
        end

        def solr_config
          Blacklight.connection_config
        end
      end
    end
  end
end
