# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bibliography Indexing' do
  let(:exhibit) { create(:exhibit) }
  let(:slug) { exhibit.slug }
  let(:doc) { { id: ['http://zotero.org/groups/1051392/items/KJERZE6Q'] } }
  let(:title_fields) do
    %i[title_245a_search title_245_search title_sort title_display title_full_display]
  end

  feature 'BibTex' do
    let(:indexer) do
      Traject::Indexer.new('exhibit_slug' => slug).tap do |i|
        i.load_config_file('lib/traject/bibtex_config.rb')
      end
    end

    scenario 'enqueues an indexing job' do
      title_fields.map { |key| doc[key] = ['Crime and Justice Under Edward III: The Case of Thomas de Lisle'] }
      full_doc = doc.to_json.unicode_normalize
      expect { indexer.process(File.open('spec/fixtures/bib.bib')) }
        .to have_enqueued_job(CreateResourceJob).with(
          'http://zotero.org/groups/1051392/items/KJERZE6Q', exhibit, full_doc
        )
    end
  end
  feature 'CSL JSON' do
    let(:indexer) do
      Traject::Indexer.new('exhibit_slug' => slug).tap do |i|
        i.load_config_file('lib/traject/csl_json_config.rb')
      end
    end

    scenario 'enqueues an indexing job' do
      title_fields.map { |key| doc[key] = ['Crime and Justice Under Edward III: The Case of Thomas de Lisle'] }
      full_doc = doc.to_json.unicode_normalize
      expect { indexer.process(File.open('spec/fixtures/bib.json')) }
        .to have_enqueued_job(CreateResourceJob).with(
          'http://zotero.org/groups/1051392/items/KJERZE6Q', exhibit, full_doc
        )
    end
  end
end
