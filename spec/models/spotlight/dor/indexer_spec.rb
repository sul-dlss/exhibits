require 'rails_helper'

describe Spotlight::Dor::Indexer do
  subject { described_class.new }

  let(:fake_druid) { 'oo000oo0000' }
  let(:resource) { Harvestdor::Indexer::Resource.new(double, fake_druid) }
  let(:solr_doc) { {} }
  let(:modsbody) { '' }
  let(:mods) do
    Nokogiri::XML <<-EOF
      <mods xmlns="#{Mods::MODS_NS}">
      #{modsbody}
      </mods>
    EOF
  end

  before do
    # reduce log noise
    allow(resource).to receive(:harvestdor_client)
    i = Harvestdor::Indexer.new
    i.logger.level = Logger::WARN
    allow(resource).to receive(:indexer).and_return i
    allow(resource).to receive(:mods).and_return(mods)
    allow(resource).to receive(:bare_druid).and_return(fake_druid)
  end

  describe '#add_content_metadata_fields' do
    before do
      allow(resource).to receive(:public_xml).and_return(public_xml)
      # stacks url calculations require the druid
      solr_doc[:id] = fake_druid
      subject.send(:add_content_metadata_fields, resource, solr_doc)
    end

    context 'without contentMetadata' do
      let(:public_xml) { Nokogiri::XML "\n<publicObject></publicObject>\n" }

      it 'is blank, except for the document id' do
        expect(solr_doc.except(:id)).to be_blank
      end
    end

    context 'with contentMetadata' do
      let(:public_xml) do
        Nokogiri::XML <<-EOF
          <publicObject>
            <contentMetadata type="image">
              <resource id="bj356mh7176_1" sequence="1" type="image">
                <label>Image 1</label>
                <file id="bj356mh7176_00_0001.jp2" mimetype="image/jp2" size="56108727">
                  <imageData width="12967" height="22970"/>
                </file>
              </resource>
            </contentMetadata>
          </publicObject>
          EOF
      end

      it 'indexes the declared content metadata type' do
        expect(solr_doc['content_metadata_type_ssim']).to eq ['image']
      end

      it 'indexes the thumbnail information' do
        expect(solr_doc['content_metadata_first_image_file_name_ssm']).to eq ['bj356mh7176_00_0001']
        expect(solr_doc['content_metadata_first_image_width_ssm']).to eq ['12967']
        expect(solr_doc['content_metadata_first_image_height_ssm']).to eq ['22970']
      end

      it 'indexes the images' do
        stacks_base_url = 'https://stacks.stanford.edu/image/iiif/oo000oo0000%2Fbj356mh7176_00_0001'
        expect(solr_doc['content_metadata_image_iiif_info_ssm']).to include "#{stacks_base_url}/info.json"
        expect(solr_doc['thumbnail_square_url_ssm']).to include "#{stacks_base_url}/square/100,100/0/default.jpg"
        expect(solr_doc['thumbnail_url_ssm']).to include "#{stacks_base_url}/full/!400,400/0/default.jpg"
        expect(solr_doc['large_image_url_ssm']).to include "#{stacks_base_url}/full/pct:25/0/default.jpg"
        expect(solr_doc['full_image_url_ssm']).to include "#{stacks_base_url}/full/full/0/default.jpg"
      end
    end
  end

  context 'Feigbenbaum specific fields concern' do
    describe '#add_document_subtype' do
      before do
        subject.send(:add_document_subtype, resource, solr_doc)
      end

      context 'without document subtype' do
        let(:modsbody) do
          <<-EOF
            <note displayLabel="preferred citation">(not a document subtype)</note>
            <note>a generic note</note>
          EOF
        end

        it 'is blank' do
          expect(solr_doc['doc_subtype_ssi']).to be_blank
        end
      end

      context 'with document subtype' do
        let(:modsbody) do
          <<-EOF
            <note displayLabel="Document subtype">memorandums</note>
            <note>a generic note</note>
          EOF
        end

        it 'extracts the doc subtypes' do
          expect(solr_doc['doc_subtype_ssi']).to eq('memorandums')
        end
      end
    end # doc subtype

    describe '#add_donor_tags' do
      before do
        subject.send(:add_donor_tags, resource, solr_doc)
      end

      context 'without donor tags' do
        let(:modsbody) { '<note displayLabel="preferred citation">(not a donor tag)</note>' }

        it 'is blank' do
          expect(solr_doc['donor_tags_ssim']).to be_blank
        end
      end

      context 'with donor tags' do
        # e.g. from https://purl.stanford.edu/vw282gv1740
        let(:modsbody) do
          <<-EOF
            <note displayLabel="Donor tags">Knowledge Systems Laboratory</note>
            <note displayLabel="Donor tags">medical applications</note>
            <note displayLabel="Donor tags">medical Applications (second word CAPPED)</note>
            <note displayLabel="Donor tags">Publishing</note>
            <note displayLabel="Donor tags">Stanford</note>
            <note displayLabel="Donor tags">Stanford Computer Science Department</note>
          EOF
        end

        it 'extracts the donor tags' do
          expect(solr_doc['donor_tags_ssim']).to contain_exactly 'Knowledge Systems Laboratory',
                                                                 'Medical applications',
                                                                 'Medical Applications (second word CAPPED)',
                                                                 'Publishing',
                                                                 'Stanford',
                                                                 'Stanford Computer Science Department'
        end
      end
    end # donor tags

    # TODO: avoid each loop around specs
    describe '#add_folder_name' do
      let(:mods_note_preferred_citation) do
        Nokogiri::XML <<-EOF
          <mods xmlns="#{Mods::MODS_NS}">
            <note type="preferred citation">#{example}</note>
          </mods>
        EOF
      end
      # example string as key, expected folder name as value
      # all from feigenbaum (or based on feigenbaum), as that is only coll with this data
      {
        'Call Number: SC0340, Accession: 1986-052, Box: 20, Folder: 40, Title: S': 'S',
        'Call Number: SC0340, Accession: 1986-052, Box: 54, Folder: 25, Title: Balzer': 'Balzer',
        'Call Number: SC0340, Accession: 1986-052, Box : 30, Folder: 21, Title: Feigenbaum, Publications. 2 of 2.': 'Feigenbaum, Publications. 2 of 2.',
        # colon in name
        'Call Number: SC0340, Accession 2005-101, Box: 10, Folder: 26, Title: Gordon Bell Letter rdf:about blah (AI) 1987': 'Gordon Bell Letter rdf:about blah (AI) 1987',
        'Call Number: SC0340, Accession 2005-101, Box: 11, Folder: 74, Title: Microcomputer Systems Proposal: blah blah': 'Microcomputer Systems Proposal: blah blah',
        'Call Number: SC0340, Accession 2005-101, Box: 14, Folder: 20, Title: blah "bleah: blargW^"ugh" seriously?.': 'blah "bleah: blargW^"ugh" seriously?.',
        # quotes in name
        'Call Number: SC0340, Accession 2005-101, Box: 29, Folder: 18, Title: "bleah" blah': '"bleah" blah',
        'Call Number: SC0340, Accession 2005-101, Box: 11, Folder: 58, Title: "M": blah': '"M": blah',
        'Call Number: SC0340, Accession 2005-101, Box : 32A, Folder: 19, Title: blah "bleah" blue': 'blah "bleah" blue',
        # not parseable
        'Call Number: SC0340, Accession 2005-101': nil,
        'Call Number: SC0340, Accession: 1986-052': nil,
        'Call Number: SC0340, Accession: 1986-052, Box 36 Folder 38': nil,
        'blah blah ... with the umbrella title Feigenbaum and Feldman, Computers and Thought II. blah blah': nil,
        'blah blah ... Title ... blah blah': nil
      }.each do |example, expected|
        describe "for example '#{example}'" do
          context 'in preferred citation note' do
            let(:example) { example }
            let(:modsbody) { %q(<note type="preferred citation">#{example}</note>) }
            before do
              allow(resource).to receive(:mods).and_return(mods_note_preferred_citation)
              subject.send(:add_folder_name, resource, solr_doc)
            end
            it "has the expected folder name '#{expected}'" do
              expect(solr_doc['folder_name_ssi']).to eq expected
            end
          end
          context 'in plain note' do
            let(:modsbody) { "<note>#{example}</note>" }
            before do
              subject.send(:add_folder_name, resource, solr_doc)
            end
            it 'does not have a folder name' do
              expect(solr_doc).not_to include 'folder_name_ssi'
            end
          end
        end # for example
      end # each
    end # add_folder_name

    describe '#add_general_notes' do
      before do
        subject.send(:add_general_notes, resource, solr_doc)
      end

      context 'no general notes, but other types of notes' do
        let(:modsbody) do
          <<-EOF
            <note displayLabel="preferred citation">(not a document subtype)</note>
            <note displayLabel="Document subtype">memorandums</note>
            <note displayLabel="Donor tags">Knowledge Systems Laboratory</note>
          EOF
        end

        it 'is blank' do
          expect(solr_doc).not_to include 'general_notes_ssim'
        end
      end

      context 'ignore extra notes' do
        let(:modsbody) do
          <<-EOF
            <note displayLabel="Document subtype">memorandums</note>
            <note>a generic note</note>
          EOF
        end

        it 'extracts the doc subtypes' do
          expect(solr_doc['general_notes_ssim']).to eq ['a generic note']
        end
      end
    end # general notes
  end # feigbenbaum specific fields concern

  context 'StanfordMods concern' do
    describe '#add_author_no_collector' do
      before do
        subject.send(:add_author_no_collector, resource, solr_doc)
      end
      let(:name) { 'Macro Hamster' }
      let(:modsbody) do
        <<-EOF
          <name type="personal">
            <namePart>#{name}</namePart>
            <role>
              <roleTerm type="code" authority="marcrelator">cre</roleTerm>
            </role>
          </name>
          <name type="personal">
            <namePart>Ignored</namePart>
            <role>
              <roleTerm type="code" authority="marcrelator">col</roleTerm>
            </role>
          </name>
        EOF
      end
      it 'populates author_no_collector_ssim field in solr doc' do
        expect(solr_doc['author_no_collector_ssim']).to eq [name]
      end
      it 'calls non_collector_person_authors on Stanford::Mods::Record object' do
        expect(resource.smods_rec).to receive(:non_collector_person_authors)
        subject.send(:add_author_no_collector, resource, solr_doc)
      end
    end

    describe '#add_box' do
      before do
        subject.send(:add_box, resource, solr_doc)
      end

      it 'without a box, box_ssi is blank' do
        expect(solr_doc['box_ssi']).to be_blank
      end

      context 'with a box' do
        let(:modsbody) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          <<-EOF
            <location>
              <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
            </location>
          EOF
        end

        it 'extracts the box' do
          expect(solr_doc['box_ssi']).to eq('10')
        end
      end
    end # add_box

    describe '#add_collector' do
      before do
        subject.send(:add_collector, resource, solr_doc)
      end
      let(:name) { 'Macro Hamster' }
      let(:modsbody) do
        <<-EOF
          <name type="personal">
            <namePart>#{name}</namePart>
            <role>
              <roleTerm type="code" authority="marcrelator">col</roleTerm>
            </role>
          </name>
        EOF
      end
      it 'populates collector_ssim field in solr doc' do
        expect(solr_doc['collector_ssim']).to eq [name]
      end
      it 'calls collectors_w_dates on Stanford::Mods::Record object' do
        expect(resource.smods_rec).to receive(:collectors_w_dates)
        subject.send(:add_collector, resource, solr_doc)
      end
    end

    describe '#add_coordinates' do
      before do
        subject.send(:add_coordinates, resource, solr_doc)
      end

      it 'without coordinates, coordinates_tesim is blank' do
        expect(solr_doc['coordinates_tesim']).to be_blank
      end

      context 'with coordinates' do
        # e.g. from https://purl.stanford.edu/vw282gv1740
        let(:modsbody) do
          <<-EOF
            <subject>
              <cartographics>
                <scale>Scale 1:500,000</scale>
                <coordinates>(W16°--E28°/N13°--S15°).</coordinates>
              </cartographics>
            </subject>
          EOF
        end

        it 'extracts the coordinates' do
          expect(solr_doc['coordinates_tesim']).to eq(['(W16°--E28°/N13°--S15°).'])
        end
      end
    end # add_coordinates

    describe '#add_geonames' do
      it 'without coordinates, geographic_srpt is blank' do
        subject.add_geonames(resource, solr_doc)
        expect(solr_doc['geographic_srpt']).to be_blank
        expect(subject.extract_geonames_ids(resource)).to be_blank
      end

      context 'without geographic data' do
        # e.g. from https://purl.stanford.edu/pj169kw1971.mods (with 2nd value added)
        let(:modsbody) do
          <<-EOF
          <subject authority="lcsh">
            <topic>Design</topic>
          </subject>
          EOF
        end

        it 'is nil' do
          expect(subject.extract_geonames_ids(resource)).to be_blank
        end
      end
      context 'with 2 geonames' do
        # e.g. from https://purl.stanford.edu/rh234sw2751.mods (with 2nd value added)
        let(:modsbody) do
          <<-EOF
            <subject>
              <geographic valueURI="http://sws.geonames.org/5350937/"/>
            </subject>
            <subject>
              <geographic valueURI="http://sws.geonames.org/5350964/"/>
            </subject>
          EOF
        end
        let(:geoname_5350937) do
          instance_double Faraday::Response, body: <<-EOF
            <geoname>
              <bbox>
                <west>-119.9344</west>
                <north>36.91154</north>
                <east>-119.655</east>
                <south>36.66216</south>
              </bbox>
            </geoname>
          EOF
        end
        let(:geoname_5350964) do
          instance_double Faraday::Response, body: <<-EOF
            <geoname>
              <bbox>
                <west>-120.91826</west>
                <north>37.58572</north>
                <east>-118.36175</east>
                <south>35.90518</south>
              </bbox>
            </geoname>
          EOF
        end

        it '#extract_geonames_ids extracts the geonames IDs' do
          expect(subject.extract_geonames_ids(resource)).to eq %w(5350937 5350964)
        end

        it 'fetches and extracts the envelopes' do
          lopes = ['ENVELOPE(-119.9344,-119.655,36.91154,36.66216)', 'ENVELOPE(-120.91826,-118.36175,37.58572,35.90518)']
          allow(Settings).to receive(:geonames_username).and_return 'foobar'
          expect(Faraday.default_connection).to receive(:get).with('http://api.geonames.org/get?geonameId=5350937&username=foobar').and_return geoname_5350937
          expect(Faraday.default_connection).to receive(:get).with('http://api.geonames.org/get?geonameId=5350964&username=foobar').and_return geoname_5350964
          subject.add_geonames(resource, solr_doc)
          expect(solr_doc['geographic_srpt']).to eq(lopes)
        end
      end
    end # add_geonames

    describe '#get_geonames_api_envelope' do
      it 'logs exceptions while returning nil' do
        allow(Settings).to receive(:geonames_username).and_return 'foobar'
        allow(Faraday.default_connection).to receive(:get).with(any_args) { raise Faraday::TimeoutError.new, 'Too slow!' }
        expect(subject.logger).to receive(:error).twice
        expect { subject.get_geonames_api_envelope('1234') }.not_to raise_error
        expect(subject.get_geonames_api_envelope('1234')).to be_nil
      end
      # otherwise tested as part of #add_geonames
    end

    describe '#add_folder' do
      before do
        subject.send(:add_folder, resource, solr_doc)
      end

      it 'without a folder, folder_ssi is blank' do
        expect(solr_doc['folder_ssi']).to be_blank
      end

      context 'with a folder' do
        # e.g. from https://purl.stanford.edu/vw282gv1740
        let(:modsbody) do
          <<-EOF
            <location>
              <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
            </location>
          EOF
        end

        it 'extracts the folder' do
          expect(solr_doc['folder_ssi']).to eq('8')
        end
      end
    end # add_folder

    describe '#add_genre' do
      before do
        subject.send(:add_genre, resource, solr_doc)
      end

      it 'without a genre, genre_ssim is blank' do
        expect(solr_doc['genre_ssim']).to be_blank
      end

      context 'with a genre' do
        # e.g. from https://purl.stanford.edu/vw282gv1740
        let(:modsbody) { '<genre authority="aat" valueURI="http://vocab.getty.edu/aat/300028579">manuscripts for publication</genre>' }
        it 'extracts the genre' do
          expect(solr_doc['genre_ssim']).to eq ['manuscripts for publication']
        end
      end
    end

    describe '#add_location' do
      before do
        subject.send(:add_location, resource, solr_doc)
      end

      it 'without a location, location_ssi is blank' do
        expect(solr_doc['location_ssi']).to be_blank
      end

      context 'with a location' do
        # e.g. from https://purl.stanford.edu/vw282gv1740
        let(:modsbody) do
          <<-EOF
            <location>
              <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
            </location>
          EOF
        end

        it 'extracts the location' do
          expect(solr_doc['location_ssi']).to eq('Series 1, Box 10, Folder 8')
        end
      end
    end # add_location

    describe '#add_point_bbox' do
      before do
        subject.send(:add_point_bbox, resource, solr_doc)
      end

      it 'without coordinates, point_bbox is blank' do
        expect(solr_doc['point_bbox']).to be_blank
      end

      context 'with coordinates' do
        # e.g. from https://purl.stanford.edu/vw282gv1740
        let(:modsbody) do
          <<-EOF
            <subject>
              <cartographics>
                <scale>Scale 1:500,000</scale>
                <coordinates>(W16°--E28°/N13°--S15°).</coordinates>
              </cartographics>
            </subject>
          EOF
        end

        it 'extracts the point_bbox' do
          expect(solr_doc['point_bbox']).to eq(['ENVELOPE(-16.0, 28.0, 13.0, -15.0)'])
        end
      end
    end # add_point_bbox

    describe '#add_series' do
      before do
        subject.send(:add_series, resource, solr_doc)
      end

      it 'without a series, series_ssi is blank' do
        expect(solr_doc['series_ssi']).to be_blank
      end

      context 'with a series' do
        # e.g. from https://purl.stanford.edu/vw282gv1740
        let(:modsbody) do
          <<-EOF
            <location>
              <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
            </location>
          EOF
        end

        it 'extracts the series' do
          expect(solr_doc['series_ssi']).to eq('1')
        end
      end
    end # add_series
  end # context StanfordMods concern

  context 'Full Text Indexing concern' do
    describe '#add_object_full_text' do
      let(:full_text_solr_fname) { 'full_text_tesimv' }
      let!(:expected_text) { 'SOME full text string that is returned from the server' }
      let!(:full_file_path) { 'https://stacks.stanford.edu/file/oo000oo0000/oo000oo0000.txt' }

      it 'indexes the full text into the appropriate field if a recognized file pattern is found' do
        public_xml_with_feigenbaum_full_text = Nokogiri::XML <<-EOF
          <publicObject id="druid:oo000oo0000" published="2015-10-17T18:24:08-07:00">
            <contentMetadata objectId="oo000oo0000" type="book">
              <resource id="oo000oo0000_4" sequence="4" type="object">
                <label>Document</label>
                <file id="oo000oo0000.pdf" mimetype="application/pdf" size="6801421"></file>
                <file id="oo000oo0000.txt" mimetype="text/plain" size="23376"></file>
              </resource>
              <resource id="oo000oo0000_5" sequence="5" type="page">
                <label>Page 1</label>
                <file id="oo000oo0000_00001.jp2" mimetype="image/jp2" size="1864266"><imageData width="2632" height="3422"/></file>
              </resource>
              </contentMetadata>
            </publicObject>
          EOF
        allow(resource).to receive(:public_xml).and_return(public_xml_with_feigenbaum_full_text)
        # don't actually attempt a call to the stacks
        allow(Faraday.default_connection).to receive(:get).with(full_file_path).and_return(instance_double(Faraday::Response, body: expected_text))
        subject.send(:add_object_full_text, resource, solr_doc)
        expect(subject.object_level_full_text_urls(resource)).to eq [full_file_path]
        expect(solr_doc[full_text_solr_fname]).to eq [expected_text]
      end

      context 'with missing full text content' do
        it 'ignores fulltext data' do
          public_xml_with_feigenbaum_full_text = Nokogiri::XML <<-EOF
            <publicObject id="druid:oo000oo0000" published="2015-10-17T18:24:08-07:00">
              <contentMetadata objectId="oo000oo0000" type="book">
                <resource id="oo000oo0000_4" sequence="4" type="object">
                  <file id="oo000oo0000.txt" mimetype="text/plain" size="23376"></file>
                </resource>
                </contentMetadata>
              </publicObject>
            EOF
          allow(resource).to receive(:public_xml).and_return(public_xml_with_feigenbaum_full_text)
          allow(Faraday.default_connection).to receive(:get).with(full_file_path).and_raise Faraday::TimeoutError.new('')

          expect(subject.logger).to receive(:error).with(/Error indexing full text/)
          subject.send(:add_object_full_text, resource, solr_doc)
          expect(solr_doc[full_text_solr_fname]).to be_blank
        end
      end

      it 'does not index the full text if no recognized pattern is found' do
        public_xml_with_no_recognized_full_text = Nokogiri::XML <<-EOF
          <publicObject id="druid:oo000oo0000" published="2015-10-17T18:24:08-07:00">
            <contentMetadata objectId="oo000oo0000" type="book">
              <resource id="oo000oo0000_4" sequence="4" type="object">
                <label>Document</label>
                <file id="oo000oo0000.pdf" mimetype="application/pdf" size="6801421"></file>
              </resource>
              <resource id="oo000oo0000_5" sequence="5" type="page">
                <label>Page 1</label>
                <file id="oo000oo0000_00001.jp2" mimetype="image/jp2" size="1864266"><imageData width="2632" height="3422"/></file>
              </resource>
              </contentMetadata>
            </publicObject>
          EOF
        allow(resource).to receive(:public_xml).and_return(public_xml_with_no_recognized_full_text)
        subject.send(:add_object_full_text, resource, solr_doc)
        expect(subject.object_level_full_text_urls(resource)).to eq []
        expect(solr_doc[full_text_solr_fname]).to be_nil
      end

      it 'indexes the full text from two files if two recognized patterns are found' do
        public_xml_with_two_recognized_full_text_files = Nokogiri::XML <<-EOF
          <publicObject id="druid:oo000oo0000" published="2015-10-17T18:24:08-07:00">
            <contentMetadata objectId="oo000oo0000" type="book">
              <resource id="oo000oo0000_4" sequence="4" type="object">
                <label>Document</label>
                <file id="oo000oo0000.pdf" mimetype="application/pdf" size="6801421"></file>
                <file id="oo000oo0000.txt" mimetype="text/plain" size="23376"></file>
              </resource>
              <resource id="oo000oo0000_5" sequence="5" type="page">
                <label>Page 1</label>
                <file id="oo000oo0000_00001.jp2" mimetype="image/jp2" size="1864266"><imageData width="2632" height="3422"/></file>
                <file id="oo000oo0000.txt" mimetype="text/plain" size="23376"></file>
              </resource>
              </contentMetadata>
            </publicObject>
          EOF
        allow(resource).to receive(:public_xml).and_return(public_xml_with_two_recognized_full_text_files)
        allow(subject).to receive(:get_file_content).with(full_file_path).and_return(expected_text)
        subject.send(:add_object_full_text, resource, solr_doc)
        expect(subject.object_level_full_text_urls(resource)).to eq [full_file_path, full_file_path]
        expect(solr_doc[full_text_solr_fname]).to eq [expected_text, expected_text] # same file twice in a 2 element array
      end
    end # add_object_full_text
  end # full text indexing concern
end
