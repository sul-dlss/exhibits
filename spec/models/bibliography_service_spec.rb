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

  describe '#api_settings_changed?' do
    it 'is true when the api_id has changed' do
      subject.api_id = 'a new id'
      subject.save
      expect(subject.api_settings_changed?).to be true
    end

    it 'is true when the api_type has changed' do
      subject.api_type = 'a new type'
      subject.save
      expect(subject.api_settings_changed?).to be true
    end

    it 'false otherwise' do
      subject.save
      expect(subject.api_settings_changed?).to be false
    end
  end

  describe '#mark_as_updated!' do
    it 'updates the sync_completed_at value' do
      subject.mark_as_updated!
      expect(subject.sync_completed_at_previously_changed?).to be true
    end
  end
end
