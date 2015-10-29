namespace :spotlight do
  desc 'Reindex the configured exhibit collections'
  task reindex: :environment do
    require 'erb'
    require 'yaml'

    exhibit_file = File.join(Rails.root, 'config', 'exhibit.yml')
    unless File.exist?(exhibit_file)
      fail "You are missing a exhibit configuration file: #{exhibit_file}"
    end

    begin
      @solr_erb = ERB.new(IO.read(exhibit_file)).result(binding)
    rescue StandardError
      raise("exhibit.yml was found, but could not be parsed with ERB. \n#{$ERROR_INFO.inspect}")
    end

    begin
      @exhibit_yml = YAML.load(@solr_erb)
    rescue StandardError
      raise("exhibit.yml was found, but could not be parsed.\n")
    end

    if @exhibit_yml.nil? || !@exhibit_yml.is_a?(Hash)
      fail("exhibit.yml was found, but was blank or malformed.\n")
    end

    @exhibit_config ||= begin
      fail "The #{::Rails.env} environment settings were not found in the exhibit.yml config" unless @exhibit_yml[::Rails.env]
      @exhibit_yml[::Rails.env].symbolize_keys
    end

    Array(@exhibit_config[:sets]).each do |set|
      indexer = Spotlight::Dor::Indexer.new
      indexer.instance_variable_set(:@solr_client, Blacklight.solr)
      indexer.config[:default_set] = set
      indexer.send(:harvestdor_client).config[:default_set] = set

      # Fix for faraday 0.9+
      indexer.send(:harvestdor_client).config[:http_options].delete(:open_timeout)
      indexer.send(:harvestdor_client).config[:http_options].delete(:timeout)

      indexer.harvest_and_index
    end

    Spotlight::SolrDocumentSidecar.group(:solr_document_id).find_each do |s|
      doc = SolrDocument.new id: s.solr_document_id
      doc.reindex
    end

    Blacklight.solr.commit
  end

  desc 'Update to the latest blacklight + spotlight dependencies'
  task upgrade: :environment do
    Bundler.with_clean_env do
      system 'bundle update blacklight blacklight-spotlight spotlight-dor-resources'
      system 'bundle exec rake blacklight:install:migrations'
      system 'bundle exec rake spotlight:install:migrations'
      system 'bundle exec rake db:migrate'
    end
  end
end
