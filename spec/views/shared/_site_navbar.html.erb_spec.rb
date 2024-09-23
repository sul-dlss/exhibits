# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_site_navbar' do
  subject { rendered }

  before do
    view.extend Spotlight::CrudLinkHelpers

    search_component = instance_double(SiteSearchFormComponent)
    allow(search_component).to receive(:render_in).and_return('search form')
    allow(SiteSearchFormComponent).to receive(:new).and_return(search_component)
  end

  context 'with a non-admin user' do
    before do
      allow(view).to receive(:can?).with([:create, :manage], Spotlight::Exhibit).and_return(false)
      allow(view).to receive(:can?).with(:create, Spotlight::Exhibit).and_return(false)
      allow(view).to receive(:can?).with(:manage, Spotlight::Exhibit).and_return(false)
      allow(view).to receive(:can?).with(:manage, Spotlight::Site.instance).and_return(false)
      render
    end

    it { is_expected.to have_link('Request an exhibit') }
    it { is_expected.not_to have_link('Create a new exhibit') }
    it { is_expected.to have_content 'search form' }
  end

  context 'with an admin user' do
    before do
      allow(view).to receive(:can?).with([:create, :manage], Spotlight::Exhibit).and_return(true)
      allow(view).to receive(:can?).with(:create, Spotlight::Exhibit).and_return(true)
      allow(view).to receive(:can?).with(:manage, Spotlight::Exhibit).and_return(true)
      allow(view).to receive(:can?).with(:manage, Spotlight::Site.instance).and_return(true)
      render
    end

    it { is_expected.to have_link('Create a new exhibit') }
  end
end
