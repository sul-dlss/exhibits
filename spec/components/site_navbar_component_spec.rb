# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteNavbarComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new).to_s)
  end

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    # rubocop:enable RSpec/AnyInstance
    search_component = instance_double(SiteSearchFormComponent)
    allow(search_component).to receive(:render_in).and_return('search form')
    allow(SiteSearchFormComponent).to receive(:new).and_return(search_component)
  end

  context 'with a non-admin user' do
    let(:user) { create(:user) }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ApplicationController).to receive(:can?).with([:create, :manage],
                                                                          Spotlight::Exhibit).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:can?).with([:create, :manage],
                                                                          Spotlight::Exhibit).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:can?).with(:create, Spotlight::Exhibit).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:can?).with(:manage, Spotlight::Exhibit).and_return(false)
      allow_any_instance_of(ApplicationController).to receive(:can?).with(:manage,
                                                                          Spotlight::Site.instance).and_return(false)
      # rubocop:enable RSpec/AnyInstance
    end

    it { expect(rendered).to have_link('Request an exhibit') }
    it { expect(rendered).not_to have_link('Create a new exhibit') }
    it { expect(rendered).to have_content 'search form' }
  end

  context 'with an admin user' do
    let(:user) { create(:admin) }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ApplicationController).to receive(:can?).with([:create, :manage],
                                                                          Spotlight::Exhibit).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:can?).with(:create, Spotlight::Exhibit).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:can?).with(:manage, Spotlight::Exhibit).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:can?).with(:manage,
                                                                          Spotlight::Site.instance).and_return(true)
      # rubocop:enable RSpec/AnyInstance
    end

    it { expect(rendered).to have_link('Create a new exhibit') }
  end
end
