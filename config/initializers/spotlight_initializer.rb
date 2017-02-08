Spotlight::Engine.config.upload_title_field = OpenStruct.new(field_name: 'title', solr_field: %w(title_full_display title_display title_245_search))
Spotlight::Engine.config.default_contact_email = Settings.default_contact_email
Spotlight::Engine.config.external_resources_partials += ['dor_harvester/form']

Spotlight::Resources::Upload.document_builder_class = ::UploadSolrDocumentBuilder
