# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnpublishedBadgeComponent, type: :component do
  it 'renders a badge with the Unpublished text' do
    rendered = render_inline(described_class.new)
    expect(rendered).to have_css('span.badge.text-bg-warning', text: 'Unpublished')
  end

  it 'appends a passed-in css class' do
    rendered = render_inline(described_class.new(class: 'unpublished'))
    expect(rendered).to have_css('span.badge.text-bg-warning.unpublished')
  end

  it 'passes through other HTML attributes' do
    rendered = render_inline(described_class.new(title: 'The Title'))
    expect(rendered).to have_css('span.badge.text-bg-warning[title="The Title"]')
  end
end
