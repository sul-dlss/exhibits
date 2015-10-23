require 'spec_helper'

describe 'indexer integration tests', :vcr do
  describe 'donor tags' do
    it 'solr_doc has donor_tags_ssim field when <note displayLabel="Donor tags"> is in MODS' do
      r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/vw282gv1740') # Feigenbaum PURL with donor tags
      solr_doc = r.to_solr.first
      expect(solr_doc['donor_tags_ssim']).to eq ['Knowledge Systems Laboratory', 'medical applications', 'Publishing', 'Stanford', 'Stanford Computer Science Department']
    end
    it 'no donor_tags_ssim field in solr doc when <note displayLabel="Donor tags"> not in MODS' do
      r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/bd955gr0721') # Revs PURL without donor tags
      solr_doc = r.to_solr.first
      expect(solr_doc['donor_tags_ssim']).to be_nil
    end
  end
  describe 'genre' do
    it 'solr_doc has genre_ssim field when <genre> in MODS' do
      r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/vw282gv1740') # Feigenbaum PURL with genre
      solr_doc = r.to_solr.first
      expect(solr_doc['genre_ssim']).to eq ['manuscripts for publication']
    end
    it 'no genre_ssim field when <genre> not in MODS' do
      r = Spotlight::Resources::Purl.new(url: 'https://purl.stanford.edu/pz816zm7931') # Road & Track PURL without genre
      solr_doc = r.to_solr.first
      expect(solr_doc['genre_ssim']).to be_nil
    end
  end
end
