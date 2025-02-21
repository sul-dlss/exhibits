# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchTipsLinkComponent, type: :component do
  subject(:rendered) do
    component = described_class.new
    allow(component).to receive(:search_tips_path).and_return('/search_tips')
    Capybara::Node::Simple.new(render_inline(component))
  end

  it 'displays search tips links' do
    expect(rendered).to have_link 'Search tips', href: '/search_tips'
  end

  it 'displays info icon' do
    expect(rendered).to have_selector('div.searchtips-link span svg.bi-info-circle')
  end
end
