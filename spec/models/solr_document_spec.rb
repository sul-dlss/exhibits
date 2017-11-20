# frozen_string_literal: true

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
        'iiif_manifest_url_ssi' => 'http://www.example.com/default/',
        'content_metadata_type_ssm' => %w(image)
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
    context 'without a whitelisted contentMetadata type' do
      subject do
        described_class.new(
          id: 'abc123',
          'iiif_manifest_url_ssi' => 'http://www.example.com/default/',
          'content_metadata_type_ssm' => %w(notanimage)
        )
      end

      it 'returns nil' do
        expect(subject.exhibit_specific_manifest(nil)).to be_nil
        expect(subject.exhibit_specific_manifest('https://www.example.com/new/{id}')).to be_nil
      end
    end
  end

  describe '#canvas?' do
    context 'when a document is a canvas' do
      subject(:document) { described_class.new(format_main_ssim: ['Page details']) }

      it { is_expected.to be_canvas }
    end

    context 'when a document is not a canvas' do
      subject(:document) { described_class.new }

      it { is_expected.not_to be_canvas }
    end
  end

  describe '#canvas' do
    subject(:canvas) do
      described_class.new(
        id: 'canvas-0fa395980b05e493948e0e2b50debd42',
        'iiif_annotation_list_url_ssim' => [
          'https://dms-data.stanford.edu/data/manifests/Parker/fh878gz0315/list/text-f254r.json'
        ],
        'iiif_canvas_id_ssim' => ['https://dms-data.stanford.edu/data/manifests/Parker/fh878gz0315/canvas/canvas-521'],
        'title_display' => ['f. 254 r'],
        'format_main_ssim' => ['Page details'],
        'annotation_tesim' => %w(These are all my annotations)
      ).canvas
    end

    it 'creates an instance from Solr document' do
      expect(canvas).to be_a Canvas
      expect(canvas.id).to eq 'canvas-0fa395980b05e493948e0e2b50debd42'
      expect(canvas.iiif_id).to eq 'https://dms-data.stanford.edu/data/manifests/Parker/fh878gz0315/canvas/canvas-521'
    end

    it 'has text content' do
      expect(canvas.label).to eq 'f. 254 r'
      expect(canvas.annotations).to eq %w(These are all my annotations)
      expect(canvas.size).to eq 5
    end

    it 'has url to annotation list data' do
      expect(canvas.annotation_lists.size).to eq 1
      expect(canvas.annotation_lists).to eq [
        'https://dms-data.stanford.edu/data/manifests/Parker/fh878gz0315/list/text-f254r.json'
      ]
    end

    pending 'Canvas should support multiple AnnotationList URLs as per IIIF spec'
  end
  describe '#mods' do
    subject(:document) { described_class.new(modsxml: '<xml></xml>') }

    it 'provides an interface into ModsDisplay' do
      expect(document.mods).to be_an ModsDisplay::HTML
    end
  end
end
