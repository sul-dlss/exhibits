namespace :spotlight do
  desc 'Reindex the configured exhibit collections'
  task reindex: :environment do
    require 'erb'
    require 'yaml'

    exhibit_file = Rails.root.join('config', 'exhibit.yml')
    unless File.exist?(exhibit_file)
      raise "You are missing a exhibit configuration file: #{exhibit_file}"
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
      raise("exhibit.yml was found, but was blank or malformed.\n")
    end

    @exhibit_config ||= begin
      raise "The #{::Rails.env} environment settings were not found in exhibit.yml" unless @exhibit_yml[::Rails.env]
      @exhibit_yml[::Rails.env].symbolize_keys
    end

    indexer = Spotlight::Dor::Indexer.new(solr_client: Blacklight.solr)

    indexer.harvest_and_index

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
