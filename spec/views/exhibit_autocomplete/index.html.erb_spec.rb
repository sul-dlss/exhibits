# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'exhibit_autocomplete/index' do
  context 'when there are no exhibits' do
    before do
      assign(:exhibits, [])
      render
    end

    it "displays a 'no matches found' message" do
      expect(rendered).to have_css('li.no-items', text: 'No matches found')
      expect(rendered).to have_css('[aria-disabled="true"]')
    end
  end

  context 'when exhibits exist' do
    let(:exhibits) do
      [
        { 'slug' => 'exhibit-1', 'title' => 'Test Exhibit', 'subtitle' => 'A Subtitle' },
        { 'slug' => 'exhibit-2', 'title' => 'Another Exhibit', 'subtitle' => nil }
      ]
    end

    before do
      assign(:exhibits, exhibits)
      allow(view).to receive(:highlight_autocomplete_suggestion) { |text| text }
      render
    end

    it 'renders each exhibit' do
      expect(rendered).to have_css('li.exhibit-result', count: 2)
    end

    it 'includes data attributes' do
      expect(rendered).to have_css('[data-autocomplete-value="exhibit-1"]')
      expect(rendered).to have_css('[data-autocomplete-title="Test Exhibit"]')
    end

    it 'renders subtitle when present' do
      expect(rendered).to have_css('.subtitle', text: 'A Subtitle')
    end

    it 'skips subtitle when not present' do
      expect(rendered).to have_css('.subtitle', count: 1)
    end
  end
end
