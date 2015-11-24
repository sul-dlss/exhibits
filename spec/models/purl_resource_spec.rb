require 'rails_helper'

describe PurlResource do
  before do
    allow_any_instance_of(Spotlight::Search).to receive(:set_default_thumbnail)
    subject.exhibit = exhibit
  end

  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe '.resources' do
    let!(:a) { exhibit.resources.new(url: 'https://purl.stanford.edu/a').becomes_provider.tap(&:save) }
    let!(:b) { exhibit.resources.new(url: 'https://purl.stanford.edu/b').becomes_provider.tap(&:save) }
    it 'enumerates all the PURL resources in an exhibit' do
      expect(described_class.resources(exhibit)).to include a, b
    end
  end

  describe '.druids' do
    let!(:a) { exhibit.resources.new(url: 'https://purl.stanford.edu/a').becomes_provider.tap(&:save) }
    let!(:b) { exhibit.resources.new(url: 'https://purl.stanford.edu/b').becomes_provider.tap(&:save) }
    it 'enumerates all the druids used in an exhibit' do
      expect(described_class.druids(exhibit)).to include 'a', 'b'
    end
  end

  describe '#save' do
    before do
      allow_any_instance_of(Spotlight::Resources::Purl).to receive(:reindex_later)
    end

    it 'creates new PURL resources' do
      subject.data = 'oo000oo0000'
      expect { subject.save }.to change { Spotlight::Resources::Purl.count }.by(1)
    end

    it 'does not create duplicate resources' do
      subject.data = <<-EOF
        oo000oo0000
        oo000oo0000
      EOF
      expect { subject.save }.to change { Spotlight::Resources::Purl.count }.by(1)
    end

    it 'triggers a (re)index job for the resources' do
      expect_any_instance_of(Spotlight::Resources::Purl).to receive(:reindex_later)
      subject.data = 'oo000oo0000'
      subject.save
    end
  end
end
