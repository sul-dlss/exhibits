# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadata::Cocina::RelatedResourceComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(related_resource:)).to_html
  end

  let(:related_resource) { CocinaDisplay::RelatedResource.new(cocina_doc) }

  context 'when the related resource has a URL and additional display data' do
    let(:cocina_doc) do
      {
        'type' => 'related to',
        'title' => [{ 'value' => 'Companion Study Materials' }],
        'access' => {
          'url' => [{ 'value' => 'https://example.com/companion' }]
        },
        'contributor' => [
          {
            'name' => [{ 'value' => 'Smith, Jane' }],
            'type' => 'person',
            'role' => [{ 'value' => 'author' }]
          }
        ]
      }
    end

    it 'renders the title as a link' do
      expect(rendered).to have_link 'Companion Study Materials',
                                    href: 'https://example.com/companion'
    end

    it 'renders the contributor in the nested display data' do
      expect(rendered).to have_css 'dl dd', text: 'Smith, Jane'
    end

    it 'does not duplicate the URL in the nested display data' do
      expect(rendered).to have_link(count: 1)
    end

    it 'does not render a details element' do
      expect(rendered).not_to have_css 'details'
    end
  end

  context 'when the resource string representation would duplicate the group label' do
    subject(:rendered) do
      render_inline(described_class.new(related_resource:,
                                        group_label: 'United States of America v. Hiroshi Tamura')).to_html
    end

    let(:cocina_doc) do
      {
        'type' => 'part of',
        'displayLabel' => 'United States of America v. Hiroshi Tamura',
        'contributor' => [
          {
            'name' => [{ 'value' => 'Tamura, Hiroshi' }],
            'role' => [{ 'value' => 'Defendant', 'code' => 'dfd' }]
          }
        ],
        'event' => [
          {
            'date' => [{ 'value' => '1948-10-29' }],
            'location' => [{ 'value' => 'Tokyo (Japan)' }]
          }
        ]
      }
    end

    it 'renders display data inline without a details element' do
      expect(rendered).not_to have_css 'details'
    end

    it 'does not render a redundant summary' do
      expect(rendered).not_to have_css 'summary'
    end

    it 'renders the nested display data' do
      expect(rendered).to have_css 'dl dd', text: 'Tamura, Hiroshi'
    end
  end

  context 'when the related resource has no URL and has display data' do
    let(:cocina_doc) do
      {
        'type' => 'has part',
        'title' => [{ 'value' => 'Manuscript Fragment' }],
        'contributor' => [
          {
            'name' => [{ 'value' => 'Nasmith, James' }],
            'type' => 'person',
            'role' => [{ 'value' => 'author' }]
          }
        ]
      }
    end

    it 'renders the title as a summary (not a link)' do
      expect(rendered).to have_css 'summary', text: 'Manuscript Fragment', visible: :all
      expect(rendered).not_to have_link 'Manuscript Fragment'
    end

    it 'renders the contributor in the nested display data' do
      expect(rendered).to have_css 'dl dd', text: 'Nasmith, James', visible: :all
    end

    it 'renders a details element for expansion' do
      expect(rendered).to have_css 'details'
    end
  end
end
