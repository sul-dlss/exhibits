require 'rails_helper'

describe SolrDocument do
  describe '#export_as_mods' do
    subject { described_class.new(modsxml: '123') }
    it 'provides the original MODS metadata' do
      expect(subject.export_as_mods).to eq '123'
    end

    context 'for a document without mods' do
      subject { described_class.new }

      it 'does not provide a MODS export' do
        expect(subject).not_to respond_to(:export_as_mods)
      end
    end
  end
  describe '#exhibit_specific_manifest' do
    subject do
      described_class.new(
        id: 'abc123',
        'iiif_manifest_url_ssi' => 'http://www.example.com/default/'
      )
    end

    context 'when missing custom_manifest_pattern' do
      it 'returns default' do
        expect(subject.exhibit_specific_manifest(nil)).to eq 'http://www.example.com/default/'
        expect(subject.exhibit_specific_manifest('')).to eq 'http://www.example.com/default/'
      end
    end
    context 'with a custom_manifest_pattern' do
      it 'provides a replaced manifest url' do
        expect(subject.exhibit_specific_manifest('https://www.example.com/new/{id}'))
          .to eq 'https://www.example.com/new/abc123'
      end
    end
  end
end
