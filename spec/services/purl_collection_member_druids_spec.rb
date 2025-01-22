# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurlCollectionMemberDruids do
  subject(:purl_collection_member_druids) { described_class.call('druid:abc123') }

  let(:purl_fetcher_client) { instance_double(PurlFetcher::Client::Reader) }

  before do
    allow(purl_fetcher_client).to receive(:collection_members).with('druid:abc123')
                                                              .and_return([{ 'druid' => 'druid:xyz789' },
                                                                           { 'druid' => 'druid:def456' }])
    allow(PurlFetcher::Client::Reader).to receive(:new).and_return(purl_fetcher_client)
  end

  it 'returns collection member druids' do
    expect(purl_collection_member_druids).to eq(['druid:xyz789', 'druid:def456'])
  end
end
