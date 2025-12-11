# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow searchworks to query for mini-bento
    origins 'http://localhost:3000',
            'http://127.0.0.1:3000',
            %r{\Ahttps://searchworks(-[a-z]{3,})?\.stanford\.edu\z}

    resource '/search', headers: :any, methods: [:get]
  end
end
