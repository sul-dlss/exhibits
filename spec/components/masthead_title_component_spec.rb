# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MastheadTitleComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(title: 'Exhibit Title',
                                                                 subtitle: 'Exhibit Subtitle')).to_s)
  end

  context 'when there is no current exhibit' do
    it { expect(rendered).to have_link('Exhibit Title', href: '/') }
    it { expect(rendered).to have_link('Exhibit Subtitle', href: '/') }
  end

  context 'when there is a current exhibit' do
    before do
      allow(vc_test_controller).to receive(:current_exhibit)
        .and_return(create(:exhibit, slug: 'exhibit-slug'))
    end

    it { expect(rendered).to have_link('Exhibit Title', href: '/exhibit-slug') }
    it { expect(rendered).to have_link('Exhibit Subtitle', href: '/exhibit-slug') }
  end
end
