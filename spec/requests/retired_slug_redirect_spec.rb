# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retired exhibit redirect' do
  it 'redirects the base slug to the replacement exhibit with a 301 status' do
    get '/supra'

    expect(response).to redirect_to('/piano-roll-program')
    expect(response).to have_http_status(:moved_permanently)
  end

  it 'redirects sub-paths to the new exhibit root' do
    get '/supra/feature/some-page'

    expect(response).to redirect_to('/piano-roll-program')
    expect(response).to have_http_status(:moved_permanently)
  end

  it 'redirects the slug when a locale is specified' do
    get '/en/supra'

    expect(response).to redirect_to('/piano-roll-program')
    expect(response).to have_http_status(:moved_permanently)
  end
end
