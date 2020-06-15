# frozen_string_literal: true

require 'rails_helper'

describe 'mirador/index.html.erb', type: :view do
  before { render }

  it 'contains mirador_bundle css' do
    expect(rendered).to have_css 'link[href*="mirador_bundle"]', visible: :hidden
  end

  it 'contains mirador_bundle js' do
    expect(rendered).to have_css 'script[src*="mirador_bundle"]', visible: :hidden
  end

  it 'contains mirador instantiation' do
    expect(rendered).to have_css 'div'
    expect(rendered).to have_css 'script', text: /Mirador\({/, visible: :hidden
  end
end
