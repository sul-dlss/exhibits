# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitTitleFieldComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(field:)) }

  let(:blacklight_config) { SearchAcrossController.blacklight_config }
  let(:field_config) { blacklight_config.index_fields[SolrDocument.exhibit_slug_field] }
  let(:document) { SolrDocument.new(id: 1, SolrDocument.exhibit_slug_field => %w(abc 123 private)) }
  let(:field) { Blacklight::FieldPresenter.new(vc_test_view_context, document, field_config) }
  let(:exhibit_metadata) do
    {
      'abc' => { 'slug' => 'abc', 'title' => 'Alphabet', 'published' => true },
      '123' => { 'slug' => '123', 'title' => nil, 'published' => true },
      'secret' => { 'slug' => 'secret', 'title' => 'Secret', 'published' => false }
    }
  end

  before do
    allow(vc_test_view_context).to receive_messages(exhibit_metadata:, blacklight_config:)
  end

  it 'is the configured component for the exhibit slug index field' do
    expect(field_config.component).to eq described_class
  end

  it 'links to the document within each accessible exhibit' do
    expect(rendered).to have_link 'Alphabet', href: '/abc/catalog/1'
    expect(rendered).to have_link '123', href: '/123/catalog/1'
    expect(rendered).to have_css 'br'
    expect(rendered).to have_no_link 'private'
    expect(rendered).to have_no_css '.badge'
  end

  context 'with an unpublished exhibit' do
    let(:document) { SolrDocument.new(id: 1, SolrDocument.exhibit_slug_field => %w(abc secret)) }

    it 'includes an Unpublished badge after the link' do
      expect(rendered).to have_link 'Secret', href: '/secret/catalog/1'
      expect(rendered).to have_css 'a + span.badge.text-bg-warning.ms-1', text: 'Unpublished'
    end
  end

  context 'when none of the exhibits are accessible' do
    let(:document) { SolrDocument.new(id: 1, SolrDocument.exhibit_slug_field => %w(private)) }

    it 'does not render' do
      expect(rendered.to_html).to be_blank
    end
  end
end
