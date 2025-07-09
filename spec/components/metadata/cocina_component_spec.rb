# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadata::CocinaComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(document: document)).to_html
  end

  before do
    allow(Settings.cocina).to receive(:metadata_display_source).and_return(true)
    stub_request(:get, "https://purl.stanford.edu/#{druid}.json").to_return(
      body: File.new(File.join(FIXTURES_PATH, "/cocina/#{druid}.json")), status: 200
    )
  end

  let(:druid) { 'hp566jq8781' }
  let(:document) { SolrDocument.new(id: druid) }

  context 'when the document has Cocina' do
    it 'renders the component' do
      expect(rendered).not_to be_empty
    end

    it 'includes a Description section' do
      expect(rendered).to have_css 'h4', text: 'Description'
      expect(rendered).to have_css 'dt', text: 'Alternative title'
      expect(rendered).to have_css 'dd', text: 'Chronica. Anglo-Saxon fragments, etc'
    end

    it 'includes an Abstract/Contents section' do
      expect(rendered).to have_css 'h4', text: 'Abstract/Contents'
      expect(rendered).to have_css 'dt', text: 'Contents'
      expect(rendered).to have_css 'dd', text: 'Polychronicon (epitome and continuation to 1429) '
    end

    it 'includes a Bibliographic information section' do
      expect(rendered).to have_css 'h4', text: 'Bibliographic information'
      expect(rendered).to have_css 'dt', text: 'Downloadable James Catalogue Record'
      expect(rendered).to have_link text: 'https://stacks.stanford.edu/file/druid:vz744tc9861/MS_367.pdf',
                                    href: 'https://stacks.stanford.edu/file/druid:vz744tc9861/MS_367.pdf'
    end

    it 'includes an Access conditions section' do
      expect(rendered).to have_css 'h4', text: 'Access conditions'
      expect(rendered).to have_css 'dt', text: 'License'
      expect(rendered).to have_css 'dd', text: 'This work is licensed under a Creative Commons Attribution Non ' \
                                               'Commercial 4.0 International license (CC BY-NC).'
    end

    context 'when the document has contacts' do
      let(:druid) { 'zb733jx3137' }

      it 'includes a Contacts section' do
        expect(rendered).to have_css 'h4', text: 'Contact information'
        expect(rendered).to have_css 'dt', text: 'Contact'
        expect(rendered).to have_link text: 'testing@me.com', href: 'mailto:testing@me.com'
      end
    end

    context 'when the document has subjects and contributors' do
      let(:druid) { 'gf752kr0559' }

      it 'includes a Contributors section' do
        expect(rendered).to have_css 'h4', text: 'Creators/Contributors'
        expect(rendered).to have_css 'dt', text: 'Interviewee'
        expect(rendered).to have_css 'dd', text: 'Osula, Anna Maria'
      end

      it 'includes a Subjects section' do
        expect(rendered).to have_css 'h4', text: 'Subjects'
        expect(rendered).to have_css 'dt', text: 'Subject'
        expect(rendered).to have_css 'dd', text: 'Estonia > Politics and government'
      end
    end
  end
end
