# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_site_sidebar', type: :view do
  subject { rendered }

  before do
    view.extend Spotlight::CrudLinkHelpers
    stub_template 'shared/_facets' => 'rendered facets'
  end

  context 'with a non-admin user' do
    before do
      allow(view).to receive(:can?).with(:create, Spotlight::Exhibit).and_return(false)
      allow(view).to receive(:can?).with(:manage, Spotlight::Site.instance).and_return(false)
      render
    end

    it { is_expected.to have_link('Request an exhibit') }
    it { is_expected.not_to have_link('Create a new exhibit') }
    it { is_expected.to have_content 'rendered facets' }
  end

  context 'with an admin user' do
    before do
      allow(view).to receive(:can?).with(:create, Spotlight::Exhibit).and_return(true)
      allow(view).to receive(:can?).with(:manage, Spotlight::Exhibit).and_return(true)
      allow(view).to receive(:can?).with(:manage, Spotlight::Site.instance).and_return(true)
      render
    end

    it { is_expected.to have_link('Create a new exhibit') }
  end
end
