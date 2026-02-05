# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'indexing integration test' do
  subject(:dor_harvester) { DorHarvester.new(druid_list: druid, exhibit: exhibit) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:rsolr) { instance_double(RSolr) }
  let(:rsolr_client) { instance_double(RSolr::Client) }

  before do
    allow(RSolr).to receive(:connect).and_return(rsolr_client)
    allow(rsolr_client).to receive(:update)
    allow(rsolr_client).to receive(:commit)

    stub_request(:post, /update/)
    %w(bb099mt5053 sj775xm6965 xf680rd3068 dx969tv9730 rk684yq9989 ms016pb9280 cf386wt1778 cc842mn9348 kh392jb5994 xy581jd9710
       vk620zs1672 ws947mh3822 gh795jd5965 hm136qv0310 kj040zn0537 jh957jy1101 nk125rg9884 ds694bw1519 vp755yy2079 ts786ny5936).each do |fixture|
      stub_request(:get, "https://purl.stanford.edu/#{fixture}.xml").to_return(
        body: File.new(File.join(FIXTURES_PATH, "#{fixture}.xml")), status: 200
      )
      stub_request(:get, "https://purl.stanford.edu/#{fixture}.json").to_return(
        body: File.new(File.join(FIXTURES_PATH, "cocina/#{fixture}.json")), status: 200
      )
    end

    stub_request(:get, 'http://api.geonames.org/get?geonameId=6255152&username=').with(
      headers: { 'Accept' => '*/*',
                 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3' }
    ).to_return(status: 200, body: '', headers: {})
  end

  context 'regular image item' do
    let(:druid) { 'xf680rd3068' }

    it 'can write the document to solr' do
      dor_harvester.reindex
    end

    context 'to_solr' do
      subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

      it 'has a doc id' do
        expect(document[:id]).to eq druid
        expect(document[:druid]).to eq druid
      end

      it 'has the gdor data' do
        expect(document).to include :modsxml, :modsxml_tsi
      end

      it 'has the fulltext url' do
        expect(document).to include url_fulltext: 'https://purl.stanford.edu/xf680rd3068'
      end

      it 'has the published date for the resource' do
        expect(document).to include last_updated: '2022-05-01T20:10:58Z'
      end

      it 'has potentially useless fields inherited from gdor indexer' do
        expect(document).to include display_type: 'image'
      end

      it 'has a iiif manifest url' do
        expect(document).to include iiif_manifest_url_ssi: 'https://purl.stanford.edu/xf680rd3068/iiif/manifest'
      end

      it 'has content metadata fields' do
        expect(document).to include content_metadata_type_ssim: ['image'],
                                    content_metadata_image_iiif_info_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/info.json'],
                                    thumbnail_square_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/square/100,100/0/default.jpg'],
                                    thumbnail_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/full/!400,400/0/default.jpg'],
                                    large_image_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/full/!1000,1000/0/default.jpg'],
                                    full_image_url_ssm: ['https://stacks.stanford.edu/image/iiif/xf680rd3068%2Fxf680rd3068_00_0001/full/!3000,3000/0/default.jpg']
      end

      it 'has MODS title fields' do
        expect(document).to include title_245_search: 'Latin glossary : small manuscript fragment on vellum.',
                                    title_245a_display: 'Latin glossary : small manuscript fragment on vellum',
                                    title_245a_search: 'Latin glossary : small manuscript fragment on vellum',
                                    title_display: 'Latin glossary : small manuscript fragment on vellum',
                                    title_sort: 'Latin glossary small manuscript fragment on vellum'
      end

      it 'has MODS author fields' do
        expect(document).to include author_sort: "\u{10FFFF} Latin glossary  small manuscript fragment on vellum"
      end

      it 'has MODS origin info fields' do
        expect(document).to include imprint_display: 'France?, [1200 - 1299?] 13th century',
                                    pub_year_isi: 1200,
                                    pub_year_no_approx_isi: 1200,
                                    pub_year_w_approx_isi: 1200,
                                    pub_year_tisim: (1200..1299).to_a,
                                    place_created_ssim: ['France?'],
                                    date_ssim: ['13th century', '[1200 - 1299?]']
      end

      it 'has other metadata fields' do
        expect(document).to include general_notes_ssim: [
                                      'Lower portion of vellum leaf, removed from a binding.',
                                      'Script: professional gotica textualis, 2 columns, with a fair amount of abbreviations.'
                                    ],
                                    folio_hrid_ss: ['a10157160'],
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

  context 'item with geographic coordinates' do
    subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

    let(:druid) { 'xy581jd9710' }

    it 'has geographic coordinates' do
      expect(document).to include geographic_srpt: ['ENVELOPE(-119.66694444444445, 168.46305555555554, -66.64972222222222, -89.88416666666667)',
                                                    'ENVELOPE(-119.667, 168.463, -66.6497, -89.8842)'],
                                  coordinates_tesim: ['W 119°40ʹ1ʺ--E 168°27ʹ47ʺ/S 66°38ʹ59ʺ--S 89°53ʹ3ʺ']
    end

    it 'has other metadata fields' do
      expect(document).to include genre_ssim: ['Geospatial data', 'cartographic dataset'],
                                  era_facet: ['1978']
    end
  end

  context 'feigenbaum item' do
    subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

    let(:druid) { 'rk684yq9989' }

    before do
      stub_request(:get, 'https://stacks.stanford.edu/file/rk684yq9989/rk684yq9989.txt').to_return(body: 'full text', status: 200)
    end

    it 'has other metadata fields' do
      expect(document).to include identifier_ssim: ['SC0340_1986-052_rk684yq9989'],
                                  author_no_collector_ssim: ['Baskett, Forest', 'Bechtolscheim, Andreus']
    end

    it 'has collection information' do
      expect(document).to include collection: ['ms016pb9280'],
                                  collection_with_title: ['ms016pb9280-|-Edward A. Feigenbaum papers, 1950-2007 (inclusive)'],
                                  collection_titles_ssim: ['Edward A. Feigenbaum papers, 1950-2007 (inclusive)']
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

    it 'has the correct date information (no blank values)' do
      expect(document).to include date_ssim: ['March 30, 1980']
    end
  end

  context 'an item with ALTO OCR' do
    subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

    let(:druid) { 'cc842mn9348' }

    before do
      fixture_file = File.new(File.join(FIXTURES_PATH, 'cc842mn9348_ocr_1.xml'))
      stub_request(
        :get,
        'https://stacks.stanford.edu/file/cc842mn9348/EastTimor_CE-SPSC_Final_Decisions_2001_04b-2001_Sabino_Gouveia_Leite_Judgment_0001.xml'
      ).to_return(body: fixture_file, status: 200)
    end

    it 'indexes all strings from the ALTO files into the full text field' do
      fulltext = document[:full_text_tesimv]
      expect(fulltext).to be_a Array
      expect(fulltext.length).to eq 1
      expect(fulltext.first).to start_with 'INTRODUCTION 1 The trial of'
      expect(fulltext.first).to end_with 'rendering of the decision.'
    end
  end

  context 'parker item' do
    subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

    let(:druid) { 'cf386wt1778' }

    it 'has parker-specific fields' do
      expect(document).to include dimensions_ssim: ['300 mm Height', '215 mm Width', '12 x 8.7 in Dimensions'],
                                  incipit_tesim: ['In illo tempore maria magdalene et maria iacobi et solomae'],
                                  manuscript_number_tesim: ['MS 69'],
                                  toc_search: ['Homiliae XL in euangelia'],
                                  url_suppl: ['https://purl.stanford.edu/kd310gm7424', 'https://purl.stanford.edu/dx969tv9730']
    end

    it 'has other fields that are present in parker data' do
      expect(document).to include identifier_ssim: ['CCCC:69', 'L. 14', '135'],
                                  repository_ssim: ['UK, Cambridge, Corpus Christi College, Parker Library'],
                                  title_variant_search: ['Gregorii Homiliae'],
                                  identifier_displayLabel_ssim: ['Source ID-|-CCCC:69', 'Stanley ID-|-L. 14', 'T. James ID-|-135']
    end
  end

  context 'collection' do
    let(:druid) { 'dx969tv9730' }
    let(:purl_fetcher_client) { instance_double(PurlFetcher::Client::Reader) }

    before do
      allow(PurlFetcher::Client::Reader).to receive(:new).and_return(purl_fetcher_client)
      allow(purl_fetcher_client).to receive(:collection_members).with(druid).and_return([])
    end

    context 'to_solr' do
      subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

      it 'has correct doc id' do
        expect(document[:id]).to eq druid
      end

      it 'has the correct collection tag' do
        expect(document[:collection_type]).to eq 'Digital Collection'
      end

      it 'has correct resource type' do
        expect(document[:format_main_ssim]).to include 'Collection'
      end

      it 'parses and reformats the timestamp to iso8601' do
        expect(document[:last_updated]).to eq '2022-04-27T13:46:06Z'
      end
    end
  end

  context 'virtual object' do
    let(:druid) { 'ws947mh3822' }

    context 'to_solr' do
      subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

      it 'has content metadata fields' do
        expect(document).to include content_metadata_type_ssim: ['image'],
                                    content_metadata_image_iiif_info_ssm: ['https://stacks.stanford.edu/image/iiif/ts786ny5936%2FPC0170_s1_E_0204/info.json'],
                                    thumbnail_square_url_ssm: %w(https://stacks.stanford.edu/image/iiif/ts786ny5936%2FPC0170_s1_E_0204/square/100,100/0/default.jpg),
                                    thumbnail_url_ssm: %w(https://stacks.stanford.edu/image/iiif/ts786ny5936%2FPC0170_s1_E_0204/full/!400,400/0/default.jpg),
                                    large_image_url_ssm: %w(https://stacks.stanford.edu/image/iiif/ts786ny5936%2FPC0170_s1_E_0204/full/!1000,1000/0/default.jpg),
                                    full_image_url_ssm: %w(https://stacks.stanford.edu/image/iiif/ts786ny5936%2FPC0170_s1_E_0204/full/!3000,3000/0/default.jpg)
      end
    end
  end

  context 'rarebooks object' do
    let(:druid) { 'hm136qv0310' }

    context 'to_solr' do
      subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

      it 'has publisher fields' do
        expect(document).to include publisher_ssim: ['D. Margand et C. Fatout'],
                                    publisher_ssi: ['D. Margand et C. Fatout'],
                                    publisher_tesim: ['D. Margand et C. Fatout']
      end
    end
  end

  context 'item with interesting name roles' do
    let(:druid) { 'kj040zn0537' }

    context 'to_solr' do
      subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

      it 'has name_ssim' do
        expect(document).to include name_ssim: ['Lasinio, Carlo, 1759-1838', 'Pellegrini, Domenico, 1759-1840', 'Vinck, Carl de, 1859-19']
      end

      it 'has name_roles_ssim' do
        expect(document).to include name_roles_ssim: ['Engraver|Lasinio, Carlo, 1759-1838', 'Artist|Pellegrini, Domenico, 1759-1840', 'Bibliographic antecedent|Pellegrini, Domenico, 1759-1840', 'Collector|Vinck, Carl de, 1859-19']
      end

      it 'author fields are populated' do
        expect(document).to include author_7xx_search: ['Lasinio, Carlo, 1759-1838', 'Pellegrini, Domenico, 1759-1840', 'Vinck, Carl de, 1859-19'],
                                    author_person_facet: ['Lasinio, Carlo, 1759-1838', 'Pellegrini, Domenico, 1759-1840', 'Vinck, Carl de, 1859-19'],
                                    author_person_display: ['Lasinio, Carlo, 1759-1838', 'Pellegrini, Domenico, 1759-1840', 'Vinck, Carl de, 1859-19'],
                                    author_person_full_display: ['Lasinio, Carlo, 1759-1838', 'Pellegrini, Domenico, 1759-1840', 'Vinck, Carl de, 1859-19']
      end
    end
  end

  context 'item with names without roles' do
    let(:druid) { 'ds694bw1519' }

    context 'to_solr' do
      subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

      it 'has name_roles_ssim' do
        expect(document).to include name_roles_ssim: ['|Packard, David, 1912-1996', '|Packard, Lucile', '|Hewlett-Packard Company', '|Hewlett, William R.']
      end

      it 'author fields are populated' do
        expect(document).to include author_1xx_search: 'Packard, David, 1912-1996',
                                    author_other_facet: ['Hewlett-Packard Company'],
                                    author_corp_display: ['Hewlett-Packard Company'],
                                    author_person_facet: ['Packard, David, 1912-1996', 'Packard, Lucile', 'Hewlett, William R.'],
                                    author_person_display: ['Packard, David, 1912-1996', 'Packard, Lucile', 'Hewlett, William R.'],
                                    author_person_full_display: ['Packard, David, 1912-1996', 'Packard, Lucile', 'Hewlett, William R.']
      end
    end
  end

  context 'item that has a collector' do
    let(:druid) { 'bb099mt5053' }

    context 'to_solr' do
      subject(:document) { indexed_documents(dor_harvester).first&.with_indifferent_access }

      it 'has collector_ssim' do
        expect(document).to include collector_ssim: ['Mandelbrot, Benoit B.']
      end
    end
  end
end
