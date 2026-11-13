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

  describe 'when the exhibit does not render a search bar' do
    it 'omits the link to search' do
      rendered = render_inline(described_class.new(render_search_link: false))
      expect(rendered).to have_link('Skip to main content', href: '#main-container')
      expect(rendered).to have_no_link('Skip to search')
    end
  end

  # Blacklight's search results view passes the link to the first result as content
  describe 'with existing search results' do
    it 'renders skip links with correct links to search and results' do
      rendered = render_inline(described_class.new) do
        vc_test_controller.view_context.render(
          Blacklight::SkipLinkItemComponent.new(text: 'Skip to first result', href: '#documents')
        )
      end
      expect(rendered).to have_link('Skip to main content', href: '#main-container')
      expect(rendered).to have_link('Skip to search', href: '#search_field')
      expect(rendered).to have_link('Skip to first result', href: '#documents')
    end
  end
end
