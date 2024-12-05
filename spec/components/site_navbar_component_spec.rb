# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteNavbarComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new).to_s)
  end

  before do
    search_component = instance_double(SiteSearchFormComponent)
    allow(search_component).to receive(:render_in).and_return('search form')
    allow(SiteSearchFormComponent).to receive(:new).and_return(search_component)
  end

  it { expect(rendered).to have_content 'search form' }
end
