# frozen_string_literal: true

require 'net/http'

# Start Solr with docker compose, yield once the core responds, then stop it.
def with_solr
  puts 'Starting Solr'
  system('docker compose up -d solr', exception: true)
  wait_for_solr
  yield
ensure
  puts 'Stopping Solr'
  system('docker compose stop solr')
end

# `docker compose up -d` returns before Solr has created the core.
def wait_for_solr(timeout: 60)
  ping = URI("http://127.0.0.1:#{ENV.fetch('SOLR_PORT', 8983)}/solr/blacklight-core/admin/ping")
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

  until solr_ping?(ping)
    if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
      system('docker compose logs solr')
      raise "Solr did not respond at #{ping} within #{timeout} seconds"
    end

    sleep 1
  end
end

def solr_ping?(uri)
  Net::HTTP.get_response(uri).is_a?(Net::HTTPSuccess)
rescue StandardError
  false
end
