# frozen_string_literal: true

##
# Ported integration test helper methods over from Spotlight
module JavascriptFeatureHelpers
  def fill_in_typeahead_field(opts = {})
    type = opts[:type] || 'twitter'
    # Poltergeist / Capybara doesn't fire the events typeahead.js
    # is listening for, so we help it out a little:
    page.execute_script <<-JS
      $("[data-#{type}-typeahead]:visible").val("#{opts[:with]}").trigger("input");
      $("[data-#{type}-typeahead]:visible").typeahead("open");
      $(".tt-suggestion").click();
    JS

    find('.tt-suggestion', text: opts[:with], match: :first).click
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

  def save_page
    sleep 1
    click_button('Save changes')
    # verify that the page was created
    expect(page).to have_content('page was successfully updated')
  end
end
