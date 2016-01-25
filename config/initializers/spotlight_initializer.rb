Spotlight::Engine.config.upload_title_field = OpenStruct.new(field_name: 'title', solr_field: %w(title_full_display title_display title_245_search))
Spotlight::Dor::Resources::Engine.config.parallel_options = Settings.indexing.parallel_options.to_h
