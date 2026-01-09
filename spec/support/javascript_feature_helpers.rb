# frozen_string_literal: true

##
# Ported integration test helper methods over from Spotlight
module JavascriptFeatureHelpers
  def fill_in_typeahead_field(opts = {})
    type = opts[:type] || 'default'
    selector = "[data-behavior='#{type}-typeahead'][role='combobox']"

    # Role=combobox indicates that the auto-complete is initialized
    find("auto-complete #{selector}").fill_in(with: opts[:with])
    # Wait for the autocomplete to show both 'open' and 'aria-expanded="true"' or the results might be stale
    expect(page).to have_css("auto-complete[open] #{selector}[aria-expanded='true']")
    first('auto-complete[open] [role="option"]', text: opts[:with]).click
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
