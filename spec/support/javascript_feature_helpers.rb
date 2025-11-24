# frozen_string_literal: true

##
# Ported integration test helper methods over from Spotlight
module JavascriptFeatureHelpers
  def fill_in_typeahead_field(opts = {})
    type = opts[:type] || 'default'

    find("auto-complete [data-behavior='#{type}-typeahead']").fill_in(with: opts[:with])
    find("auto-complete[open] [role='option']", text: opts[:with], match: :first).click
  end

  def add_widget(type)
    click_add_widget

    # click the item + image widget
    expect(page).to have_css("button[data-type='#{type}']")
    find("button[data-type='#{type}']").click
  end

  def click_add_widget
    if all('.st-block-replacer').blank?
      expect(page).to have_css('.st-block-addition')
      first('.st-block-addition').click
    end
    expect(page).to have_css('.st-block-replacer')
    first('.st-block-replacer').click
  end
end
