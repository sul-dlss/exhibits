require 'rails_helper'

describe SyncBibliographyService do
  subject(:service) { described_class.new(exhibit) }
  let(:exhibit) { create(:exhibit) }
  let(:bibliography_service) { BibliographyService.create(api_id: 'abc123', api_type: 'user', exhibit_id: exhibit.id) }
  let(:resource1) { instance_spy(Spotlight::Resource) }
  let(:resource2) { create(:resource) }
  let(:resources) { [resource1, resource2] }

  describe 'validation' do
    context 'when an exhibit does not have a configured bibliography' do
      it 'an error is raised ' do
        expect { service }.to raise_error(
          ArgumentError,
          'The provided exhibit did not have a properly configured bibliography service.'
        )
      end
    end

    context 'when an exhibit does not have any resources' do
      it 'an error is raised' do
        bibliography_service
        expect { service }.to raise_error(
          ArgumentError,
          'The provided exhibit did not have any resources.'
        )
      end
    end

    context 'when valid' do
      it 'allows initialization' do
        bibliography_service # calling so the givin exhibit has bibliographies associated
        expect(exhibit).to receive_messages(resources: resources)
        expect { service }.not_to raise_error
      end
    end
  end

  describe 'sync' do
    let(:api) { instance_double(ZoteroApi::Client) }
    let(:sidecar1) { instance_spy(Spotlight::SolrDocumentSidecar, document_id: 'abc123', data: {}) }
    let(:sidecar2) { instance_spy(Spotlight::SolrDocumentSidecar, document_id: 'def456', data: {}) }
    let(:sidecars) { [sidecar1, sidecar2] }
    before do
      bibliography_service
      expect(exhibit).to receive_messages(resources: resources)
      expect(resource1).to receive_messages(
        solr_document_sidecars: sidecars
      )
      expect(service).to receive_messages(bibliography_api: api)
    end

    it 'updates the given bibliography_service to indicate a sync has happened' do
      expect(api).to receive_messages(bibliography_for: nil)
      expect_any_instance_of(BibliographyService).to receive(:mark_as_updated!)
      service.sync
    end

    context 'when a document has a matching bibliography' do
      before do
        expect(api).to receive_messages(
          bibliography_for: instance_double(ZoteroApi::Bibliography, render: '<bibliography />')
        )
        sidecars.each do |sidecar|
          expect(sidecar).to receive_messages(save: true)
        end
      end
      it 'the bibliogrpahy is updated in the document' do
        expect(resource1).to receive_messages(reindex_later: true)
        service.sync
        sidecars.each do |sidecar|
          expect(sidecar.data[Settings.zotero_api.solr_document_field]).to eq '<bibliography />'
        end
      end
    end

    context 'when a document does not have a matching bibliography, but has a pre-existing bibliography' do
      before do
        sidecars.each do |sidecar|
          sidecar.data[Settings.zotero_api.solr_document_field] = '<an-existing-bibliography />'
          expect(sidecar.data[Settings.zotero_api.solr_document_field]).not_to be_nil
          expect(sidecar).to receive_messages(save: true)
        end
        expect(api).to receive_messages(bibliography_for: nil)
      end
      it 'the bibliography is deleted from the document' do
        expect(resource1).to receive_messages(reindex_later: true)
        service.sync
        sidecars.each do |sidecar|
          expect(sidecar.data[Settings.zotero_api.solr_document_field]).to be_nil
        end
      end
    end

    context 'when an item does not have a matching bibliography and does not have a pre-existing bibliography' do
      before do
        expect(api).to receive_messages(bibliography_for: nil)
      end
      it 'the document is not updated' do
        service.sync
        expect(resource1).not_to have_received(:reindex_later)
        sidecars.each do |sidecar|
          expect(sidecar).not_to have_received(:save)
        end
      end
    end
  end
end
