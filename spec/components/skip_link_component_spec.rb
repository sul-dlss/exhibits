# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SkipLinkComponent, type: :component do
  subject(:rendered) { Capybara::Node::Simple.new(render_inline(described_class.new)) }

  it { expect(rendered).to have_css('#skip-link-exhibits.visually-hidden-focusable') }
  it { expect(rendered).to have_css('a.visually-hidden-focusable.rounded-bottom', visible: false, count: 3) }
end
