# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteNavbarComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new).to_s)
  end

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
    search_component = instance_double(SiteSearchFormComponent)
    allow(search_component).to receive(:render_in).and_return('search form')
    allow(SiteSearchFormComponent).to receive(:new).and_return(search_component)
  end

  context 'with a non-admin user' do
    let(:user) { create(:user) }

    it { expect(rendered).to have_link('Request an exhibit') }
    it { expect(rendered).not_to have_link('Create a new exhibit') }
    it { expect(rendered).to have_content 'search form' }
  end

  context 'with an admin user' do
    let(:user) { create(:site_admin) }

    it { expect(rendered).to have_link('Create a new exhibit') }
  end
end
