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
end
