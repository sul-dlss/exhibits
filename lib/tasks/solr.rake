# frozen_string_literal: true

require 'net/http'

# Run Solr with docker compose when the Docker daemon is running, otherwise with solr_wrapper.
def with_solr(&)
  if system('docker info', out: File::NULL, err: File::NULL)
    with_docker_solr(&)
  else
    with_solr_wrapper(&)
  end
end

def with_docker_solr
  puts 'Starting Solr'
  system('docker compose up -d solr', exception: true)
  wait_for_solr
  yield
ensure
  puts 'Stopping Solr'
  system('docker compose stop solr')
end

def with_solr_wrapper(&)
  require 'solr_wrapper'

  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: Rails.root.join('solr/config'), &)
  end
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
