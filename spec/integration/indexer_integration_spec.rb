require 'spec_helper'

describe 'indexer integration tests', :vcr do
  it 'indexes donor tags when they exist' do
    r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/vw282gv1740') # Feigenbaum PURL with donor tags
    solr_doc = r.to_solr.first
    expect(solr_doc['donor_tags_ssim']).to eq ['Knowledge Systems Laboratory', 'medical applications', 'Publishing', 'Stanford', 'Stanford Computer Science Department']
  end
  it 'does not index donor tags when they do not exist' do
    r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/bd955gr0721') # Revs PURL without donor tags
    solr_doc = r.to_solr.first
    expect(solr_doc['donor_tags_ssim']).to be_nil
  end
  it 'indexes genre' do
    r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/vw282gv1740') # Feigenbaum PURL with genre
    solr_doc = r.to_solr.first
    expect(solr_doc['genre_ssim']).to eq ['manuscripts for publication']
  end
  it 'does not index genre when it does not exist' do
    r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/pz816zm7931') # Road & Track PURL without genre
    solr_doc = r.to_solr.first
    expect(solr_doc['genre_ssim']).to be_nil
  end
end
