# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadata::SectionComponent, type: :component do
  subject(:rendered) do
    render_inline described_class.new(label: 'Field heading') do
      '<dt>Field name</dt><dd>Field values</dd>'
    end.to_html
  end

  it 'renders the heading' do
    expect(rendered).to have_css 'h4', text: 'Field heading'
  end

  it 'renders the metadata' do
    expect(rendered).to have_css 'div.section-body dl', text: 'Field name'
    expect(rendered).to have_css 'div.section-body dl', text: 'Field values'
  end
end
