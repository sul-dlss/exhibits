Spotlight::Engine.config.upload_title_field = OpenStruct.new(field_name: 'title', solr_field: %w(title_full_display title_display title_245_search title_sort))
Spotlight::Engine.config.upload_fields = [
  OpenStruct.new(field_name: Spotlight::Engine.config.upload_description_field, label: 'Description', form_field_type: :text_area),
  OpenStruct.new(field_name: :spotlight_upload_attribution_tesim, label: 'Attribution'),
  OpenStruct.new(field_name: 'date', solr_field: %w(spotlight_upload_date_tesim date_sort), label: 'Date')
]
Spotlight::Engine.config.default_contact_email = Settings.default_contact_email
Spotlight::Engine.config.external_resources_partials += ['dor_harvester/form']

Spotlight::Resources::Upload.document_builder_class = ::UploadSolrDocumentBuilder
