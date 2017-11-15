# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'indexing integration test', type: :feature, vcr: true do
  subject(:dor_harvester) { DorHarvester.new(druid_list: druid, exhibit: exhibit) }

  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    stub_request(:post, /update/)
    %w(xf680rd3068 dx969tv9730 rk684yq9989 ms016pb9280 cf386wt1778).each do |fixture|
      stub_request(:get, "https://purl.stanford.edu/#{fixture}.xml").to_return(
        body: File.new(File.join(FIXTURES_PATH, "#{fixture}.xml")), status: 200
      )
      stub_request(:get, "https://purl.stanford.edu/#{fixture}.mods").to_return(
        body: File.new(File.join(FIXTURES_PATH, "#{fixture}.mods")), status: 200
      )
    end
  end

  context 'regular image item' do
    let(:druid) { 'xf680rd3068' }

    it 'can write the document to solr' do
      dor_harvester.reindex
    end

    context 'to_solr' do
      subject(:document) do
        dor_harvester.document_builder.to_solr.first
      end

      it 'has a doc id' do
        expect(document[:id]).to eq druid
        expect(document[:druid]).to eq druid
      end

      it 'has the gdor data' do
        expect(document).to include :modsxml, :url_fulltext, :all_search
      end

      it 'has potentially useless fields inherited from gdor indexer' do
        expect(document).to include display_type: 'image'
      end

      it 'has a iiif manifest url' do
        expect(document).to include iiif_manifest_url_ssi: 'https://purl.stanford.edu/xf680rd3068/iiif/manifest'
      end

      it 'has content metadata fields' do
        expect(document).to include content_metadata_type_ssim: ['image'],
                                    content_metadata_first_image_file_name_ssm: ['xf680rd3068_00_0001'],
                                    content_metadata_first_image_width_ssm: ['1794'],
                                    content_metadata_first_image_height_ssm: ['2627'],
                                    content_metadata_image_iiif_info_ssm: %w(https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/info.json https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0002/info.json),
                                    thumbnail_square_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/square/100,100/0/default.jpg', 'https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0002/square/100,100/0/default.jpg'],
                                    thumbnail_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/full/!400,400/0/default.jpg', 'https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0002/full/!400,400/0/default.jpg'],
                                    large_image_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/full/!1000,1000/0/default.jpg', 'https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0002/full/!1000,1000/0/default.jpg'],
                                    full_image_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/full/!3000,3000/0/default.jpg', 'https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0002/full/!3000,3000/0/default.jpg']
      end

      it 'has MODS title fields' do
        expect(document).to include title_245_search: 'Latin glossary : small manuscript fragment on vellum.',
                                    title_245a_display: 'Latin glossary : small manuscript fragment on vellum',
                                    title_245a_search: 'Latin glossary : small manuscript fragment on vellum',
                                    title_display: 'Latin glossary : small manuscript fragment on vellum',
                                    title_full_display: 'Latin glossary : small manuscript fragment on vellum.',
                                    title_sort: 'Latin glossary small manuscript fragment on vellum'
      end

      it 'has MODS author fields' do
        expect(document).to include author_sort: "\u{10FFFF} Latin glossary  small manuscript fragment on vellum"
      end

      it 'has MODS date fields' do
        expect(document).to include imprint_display: 'France?, [1200 - 1299?] 13th century',
                                    pub_year_isi: 1200,
                                    pub_year_no_approx_isi: 1200,
                                    pub_year_w_approx_isi: 1200
      end

      it 'has other metadata fields' do
        expect(document).to include general_notes_ssim: [
          'Lower portion of vellum leaf, removed from a binding.',
          'Script: professional gotica textualis, 2 columns, with a fair amount of abbreviations.'
        ],
                                    topic_search: ['Manuscripts, Latin (Medieval and modern)'],
                                    geographic_search: ['France'],
                                    subject_all_search: ['Manuscripts, Latin (Medieval and modern)', 'France'],
                                    topic_facet: ['Manuscripts, Latin (Medieval and modern)'],
                                    geographic_facet: ['France'],
                                    format_main_ssim: ['Archive/Manuscript'],
                                    language: ['Latin'],
                                    physical: ['1 fragment, 96 x 151 mm.'],
                                    summary_search: [start_with('Unidentified Latin vocabulary')],
                                    pub_search: ['fr', 'France?']
      end

      it 'has spotlight data' do
        expect(document).to include :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end
    end
  end

  context 'feigenbaum item' do
    subject(:document) do
      dor_harvester.document_builder.to_solr.first
    end

    let(:druid) { 'rk684yq9989' }

    before do
      stub_request(:get, 'https://stacks.stanford.edu/file/rk684yq9989/rk684yq9989.txt').to_return(body: 'full text', status: 200)
    end

    it 'has collection information' do
      expect(document).to include collection: ['ms016pb9280'],
                                  collection_with_title: ['ms016pb9280-|-Edward A. Feigenbaum papers, 1950-2007 (inclusive)']
    end

    it 'has feigenbaum-specific fields' do
      expect(document).to include box_ssi: '1',
                                  folder_ssi: '6',
                                  folder_name_ssi: 'SUN Write-ups and View Graphs',
                                  location_ssi: 'Call Number: SC0340, Accession: 1986-052, Box: 1, Folder: 6',
                                  series_ssi: '1986-052',
                                  donor_tags_ssim: ['Computer Science Department', 'SUN']
    end

    it 'indexes full text content' do
      expect(document).to include full_text_tesimv: ['full text']
    end
  end

  context 'parker item' do
    subject(:document) do
      dor_harvester.document_builder.to_solr.first
    end

    let(:druid) { 'cf386wt1778' }

    it 'has parker-specific fields' do
      expect(document).to include incipit_tesim: ['In illo tempore maria magdalene et maria iacobi et solomae'],
                                  manuscript_titles_tesim: ['M.R. James Title-|-Gregorii Homiliae'],
                                  manuscript_number_tesim: ['MS 69'],
                                  toc_search: ['Homiliae XL in euangelia'],
                                  url_suppl: ['https://purl.stanford.edu/kd310gm7424', 'https://purl.stanford.edu/dx969tv9730']
    end
  end

  context 'collection' do
    let(:druid) { 'dx969tv9730' }

    context 'to_solr' do
      subject(:document) do
        dor_harvester.document_builder.to_solr.first
      end

      before do
        allow(dor_harvester).to receive(:size).and_return(556)
      end

      it 'has correct doc id' do
        expect(document[:id]).to eq druid
      end

      it 'has the correct collection tag' do
        expect(document[:collection_type]).to eq 'Digital Collection'
      end

      it 'has correct resource type' do
        expect(document[:format_main_ssim]).to include 'Collection'
      end

      it 'has correct content metadata type' do
        expect(document[:content_metadata_type_ssm]).to include 'file'
      end
    end
  end
end
