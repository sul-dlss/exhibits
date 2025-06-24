# frozen_string_literal: true

# Configure folio_client singleton
begin
  FolioClient.configure(
    url: Settings.folio.url,
    login_params: {
      username: Settings.folio.username,
      password: Settings.folio.password,
      legacy_auth: Settings.folio.legacy_auth
    },
    okapi_headers: {
      'X-Okapi-Tenant': Settings.folio.tenant_id,
      'User-Agent': "folio_client #{FolioClient::VERSION}; exhibits #{Rails.env}"
    }
  )
rescue StandardError => e
  # as of v0.1.0, folio_client tries to connect immediately upon configuration, which would
  # prevent running tests or rails console on laptop.  would also prevent deployment or startup
  # of dor-services-app if configuration was incorrect (missing settings, stale password, etc).
  Rails.logger.warn("Error configuring FolioClient: #{e}")
  Honeybadger.notify(e)
end
