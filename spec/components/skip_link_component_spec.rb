# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SkipLinkComponent, type: :component do
  describe 'no search results' do
    before do
      render_inline(described_class.new)
    end

    it { expect(page).to have_css('#skip-link-exhibits.visually-hidden-focusable') }
    it { expect(page).to have_css('a.d-inline-flex.m-1', visible: false, count: 2) }
  end

  # If an existing content block is passed to this component,
  # the component should include the link to the first result
  describe 'with existing search results' do
    before do
      render_inline(described_class.new) do
        'something'
      end
    end

    it { expect(page).to have_css('a.d-inline-flex.m-1', visible: false, count: 3) }
    it { expect(page).to have_link(href: '#documents') }
  end
end
