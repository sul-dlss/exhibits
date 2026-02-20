Rails.application.config.to_prepare do
  Blacklight::Configuration.default_values[:search_state_fields] ||= []
  Blacklight::Configuration.default_values[:search_state_fields] += %i[locale group]
end

Spotlight::Engine.config.upload_title_field = Spotlight::UploadFieldConfig.new(
  solr_fields: %w(title_display title_245_search title_sort spotlight_upload_title_tesim),
  field_name: :spotlight_upload_title_tesim,
  label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_title_tesim') }
)

Spotlight::Engine.config.iiif_title_fields = %w(title_display title_245_search title_sort spotlight_upload_title_tesim)

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
    solr_fields: [
      'date_sort',
      'spotlight_upload_date_tesim',
      pub_year_w_approx_isi: lambda { |value| CocinaDisplay::Dates::Date.from_cocina({"value" => value }).date&.year if value },
      pub_year_tisim: lambda { |value| CocinaDisplay::Dates::Date.from_cocina({"value" => value }).date&.year if value },
      pub_year_isi: lambda { |value| CocinaDisplay::Dates::Date.from_cocina({"value" => value }).date&.year if value }
    ],
    field_name: :spotlight_upload_date_tesim,
    label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_date_tesim') }
  )
]
Spotlight::Engine.config.default_contact_email = Settings.default_contact_email
Spotlight::Engine.config.external_resources_partials += ['dor_harvester/form', 'bibliography_resources/form']

ActiveSupport::Reloader.to_prepare do
  Spotlight::Resources::Upload.indexing_pipeline.transforms << (lambda do |data, pipeline|
    resource = pipeline.context.resource
    riiif = Riiif::Engine.routes.url_helpers

    # Skip for uploaded items without thumbnails
    next data if resource.upload_id.blank?

    data.merge({
      thumbnail_square_url_ssm: riiif.image_path(resource.upload_id, region: 'square', size: '100,100'),
      large_image_url_ssm: riiif.image_path(resource.upload_id, region: 'full', size: '!1000,1000'),
    })
  end)

  Spotlight::Etl::Context.error_reporter = lambda do |pipeline, exception, data|
    if pipeline.context.resource.is_a? DorHarvester
      message = exception.inspect.truncate(1.megabyte)
      RecordIndexStatusJob.perform_later(pipeline.context.resource, pipeline.source&.bare_druid, ok: false, message: message)

      Honeybadger.notify(exception, context: { exhibit: pipeline.context.resource.exhibit_id, druid: pipeline.source&.bare_druid, resource_id: pipeline.context.resource.id })
    else
      Honeybadger.notify(exception, context: { exhibit: pipeline.context.resource.exhibit_id, resource_id: pipeline.context.resource.id })
    end
  end
end

Spotlight::Engine.config.exhibit_themes = %w[default parker] if FeatureFlags.new.themes?

Exhibits::Application.config.after_initialize do
  Spotlight::Exhibit.themes_selector = ->(exhibit) do
    themes = Settings.exhibit_themes

    themes[exhibit&.slug] || themes[:default]
  end
end

Spotlight::Engine.config.default_autocomplete_params = {
  qf: 'id^1000 title_245_unstem_search^200 title_245_search^100 id_ng^50 full_title_ng^50 all_search'
}

Spotlight::Engine.config.sir_trevor_widgets = %w[
  Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse LinkToSearch
  FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
  SolrDocumentsFeatures SolrDocumentsGrid SearchResults
]


Spotlight::Engine.config.site_tags = [
  "Arts & Humanities",
  "Government & Society",
  "Maps & Geography",
  "Science & Engineering",
  "Social justice",
  "Stanfordiana"
]

# Arabic support is incomplete, but because Blacklight and Spotlight include Arabic translations we must set the
# list of available locales to prevent Exhibit creators from selecting it.
Spotlight::Engine.config.i18n.available_locales = [:de, :en, :es, :fr, :hu, :it, :nl, 'pt-BR', :sq, :zh]
