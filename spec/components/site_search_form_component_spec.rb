# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteSearchFormComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(url: '/form/path', params: { some: 'param' })).to_s)
  end

  it { expect(rendered).to have_css('form[action="/form/path"]') }
  it { expect(rendered).to have_css('.dropdown-menu', visible: false) }
end
