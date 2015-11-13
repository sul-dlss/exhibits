require 'rails_helper'

describe 'an exhibit' do
  it 'loads the home page' do
    visit '/'
  end
  it 'has working full text fielded search' do
    visit '/'
    fill_in 'q', with: 'cobbler'
    select 'Full text', from: 'search_field'
    click_button 'search'
    expect(page.status_code).to eq 200
  end
end
