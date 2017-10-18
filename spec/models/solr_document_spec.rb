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
    context 'without an indexed manifest' do
      subject { described_class.new }

      it 'returns nil' do
        expect(subject.exhibit_specific_manifest('present')).to be_nil
      end
    end
  end

  describe '#annotation' do
    subject(:annotation) do
      described_class.new(
        id: 'anno123',
        'format_main_ssim' => %w(Annotation),
        'annotation_tesim' => %w(This\ is\ my\ annotation),
        'xywh_ssim' => %w(10,20,30,40),
        'canvas_ssim' => %w(canvas456),
        'related_document_id_ssim' => %w(aa111bb2222),
        'language' => %w(Latin),
        'motivation_ssim' => %w(sc:commenting)
      ).annotation
    end

    it 'creates an instance from Solr document' do
      expect(annotation).to be_an Annotation
      expect(annotation.id).to eq 'anno123'
    end

    it 'has text content' do
      expect(annotation.text).to be_an Annotation::Text
      expect(annotation.content).to eq 'This is my annotation'
      expect(annotation.language).to eq 'Latin'
      expect(annotation.format).to eq 'text/plain'
    end

    it 'has target content' do
      expect(annotation.target).to be_an Annotation::Target
      expect(annotation.xywh).to eq '10,20,30,40'
      expect(annotation.canvas).to eq 'canvas456'
      expect(annotation.druid).to eq 'aa111bb2222'
      expect(annotation.on).to eq 'canvas456#xywh=10,20,30,40'
    end

    it 'has misc content' do
      expect(annotation.motivation).to eq 'sc:commenting'
    end
  end
end
