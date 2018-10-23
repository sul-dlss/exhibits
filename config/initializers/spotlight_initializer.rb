Spotlight::Engine.config.upload_title_field = Spotlight::UploadFieldConfig.new(
  solr_fields: %w(title title_full_display title_display title_245_search title_sort spotlight_upload_title_tesim),
  field_name: :spotlight_upload_title_tesim,
  label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_title_tesim') }
)
Spotlight::Engine.config.upload_fields = [
  Spotlight::UploadFieldConfig.new(
    field_name: Spotlight::Engine.config.upload_description_field,
    label: -> { I18n.t(:"spotlight.search.fields.#{Spotlight::Engine.config.upload_description_field}") },
    form_field_type: :text_area
  ),
  Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_upload_attribution_tesim,
    label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_attribution_tesim') }
  ),
  Spotlight::UploadFieldConfig.new(
    field_name: :spotlight_upload_date_tesim,
    label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_date_tesim') }
  )
]
Spotlight::Engine.config.default_contact_email = Settings.default_contact_email
Spotlight::Engine.config.external_resources_partials += ['dor_harvester/form', 'bibliography_resources/form']

Spotlight::Resources::Upload.document_builder_class = ::UploadSolrDocumentBuilder

Spotlight::Engine.config.exhibit_themes = %w[default parker] if FeatureFlags.new.themes?
