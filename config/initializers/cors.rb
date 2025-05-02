# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow searchworks to query for mini-bento
    origins 'http://localhost:3000',
            'http://127.0.0.1:3000',
            %r{\Ahttps://([a-z]{3,}-)?searchworks\.stanford\.edu\z}

    resource '/search', headers: :any, methods: [:get]
  end
end
