# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SkipLinkComponent, type: :component do
  describe 'no search results' do
    it 'renders skip links with correct link to search' do
      rendered = render_inline(described_class.new)
      expect(rendered).to have_link('Skip to main content', href: '#main-container')
      expect(rendered).to have_link('Skip to search', href: '#search_field')
    end
  end

  # If an existing content block is passed to this component,
  # the component should include the link to the first result
  describe 'with existing search results' do
    it 'renders skip links with correct links to search and results' do
      rendered = render_inline(described_class.new) { 'some content' }
      expect(rendered).to have_link('Skip to main content', href: '#main-container')
      expect(rendered).to have_link('Skip to search', href: '#search_field')
      expect(rendered).to have_link('Skip to first result', href: '#documents')
    end
  end
end
