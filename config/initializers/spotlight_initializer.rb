Spotlight::Engine.config.new_resource_partials += ['purl_resources/form']
Spotlight::Engine.config.upload_title_field = OpenStruct.new(field_name: 'title', solr_field: %w(title_full_display title_display title_245_search))
