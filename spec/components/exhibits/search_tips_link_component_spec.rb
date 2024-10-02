# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exhibits::SearchTipsLinkComponent, type: :component do
  subject(:rendered) { Capybara::Node::Simple.new(render_inline(described_class.new)) }

  it 'displays seearch tips links' do
    expect(rendered).to have_link('Search tips'), href: '/search_tips'
  end

  it 'displays info icon' do
    expect(rendered).to have_selector('div.searchtips-link span svg.bi-info-circle')
  end
end
