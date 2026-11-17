# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LeafletMapFieldComponent, type: :component do
  subject(:rendered) do
    with_controller_class(CatalogController) { render_inline(described_class.new(field:, show: true)) }
  end

  let(:document) { SolrDocument.new(id: 'abc123', geographic_srpt: ['ENVELOPE(-122.2, -122.1, 37.5, 37.4)']) }
  let(:field_config) { CatalogController.blacklight_config.index_fields['geographic_srpt'] }
  let(:field) { Blacklight::FieldPresenter.new(CatalogController.new.view_context, document, field_config) }

  before do
    allow(field).to receive(:render_field?).and_return(true)
  end

  it 'renders the leaflet map in a wrapper' do
    expect(rendered).to have_css 'dt', text: 'Inline Map'
    expect(rendered).to have_css 'dd .blacklight-heatmaps-show-map-wrapper .blacklight-heatmaps-show-map#map-abc123'
  end
end
