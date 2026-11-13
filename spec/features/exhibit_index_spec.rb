# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'the exhibit home page' do
  it 'loads the home page' do
    visit '/'
    expect(page.status_code).to eq 200
  end
end
