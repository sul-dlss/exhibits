require 'rails_helper'

describe BibliographyService do
  describe '#header' do
    it 'has a default value' do
      expect(subject.header).to eq 'Bibliography'
    end

    it 'returns the set value' do
      subject.header = 'Something else'
      subject.save
      subject.reload
      expect(subject.header).to eq 'Something else'
    end
  end

  describe '#initial_sync_complete?' do
    it 'is true when the sync_completed_at has been set' do
      subject.sync_completed_at = DateTime.current
      expect(subject.initial_sync_complete?).to be true
    end

    it 'is false when a sync_completed_at is not present' do
      expect(subject.initial_sync_complete?).to be false
    end
  end
end
