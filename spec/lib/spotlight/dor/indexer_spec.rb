require 'spec_helper'

describe Spotlight::Dor::Indexer do
  subject { described_class.new }

  let(:fake_druid) { 'oo000oo0000' }
  let(:r) { Harvestdor::Indexer::Resource.new(double, fake_druid) }
  let(:sdb) { GDor::Indexer::SolrDocBuilder.new(r, Logger.new(StringIO.new)) }
  let(:solr_doc) { {} }

  before do
    # reduce log noise
    allow(r).to receive(:harvestdor_client)
    i = Harvestdor::Indexer.new
    i.logger.level = Logger::WARN
    allow(r).to receive(:indexer).and_return i
  end

  describe '#add_content_metadata_fields' do
    before do
      allow(r).to receive(:public_xml).and_return(public_xml)
      allow(sdb).to receive(:bare_druid).and_return(fake_druid)

      # stacks url calculations require the druid
      solr_doc[:id] = fake_druid

      subject.send(:add_content_metadata_fields, sdb, solr_doc)
    end

    context 'with a record without contentMetadata' do
      let(:public_xml) do
        Nokogiri::XML <<-EOF
          <publicObject></publicObject>
          EOF
      end

      it 'is blank, except for the document id' do
        expect(solr_doc.except(:id)).to be_blank
      end
    end

    context 'with a record with contentMetadata' do
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
        expect(solr_doc['content_metadata_type_ssim']).to contain_exactly 'image'
      end

      it 'indexes the thumbnail information' do
        expect(solr_doc['content_metadata_first_image_file_name_ssm']).to contain_exactly 'bj356mh7176_00_0001'
        expect(solr_doc['content_metadata_first_image_width_ssm']).to contain_exactly '12967'
        expect(solr_doc['content_metadata_first_image_height_ssm']).to contain_exactly '22970'
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
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_document_subtype, sdb, solr_doc)
      end

      context 'with a record without document subtype' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <note displayLabel="preferred citation">(not a document subtype)</note>
              <note>a generic note</note>
            </mods>
            EOF
        end

        it 'is blank' do
          expect(solr_doc['doc_subtype_ssi']).to be_blank
        end
      end

      context 'with a record with document subtype' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <note displayLabel="Document subtype">memorandums</note>
              <note>a generic note</note>
            </mods>
            EOF
        end

        it 'extracts the doc subtypes' do
          expect(solr_doc['doc_subtype_ssi']).to eq('memorandums')
        end
      end
    end # doc subtype

    describe '#add_donor_tags' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_donor_tags, sdb, solr_doc)
      end

      context 'with a record without donor tags' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <note displayLabel="preferred citation">(not a donor tag)</note>
            </mods>
            EOF
        end

        it 'is blank' do
          expect(solr_doc['donor_tags_ssim']).to be_blank
        end
      end

      context 'with a record with donor tags' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <note displayLabel="Donor tags">Knowledge Systems Laboratory</note>
              <note displayLabel="Donor tags">medical applications</note>
              <note displayLabel="Donor tags">Publishing</note>
              <note displayLabel="Donor tags">Stanford</note>
              <note displayLabel="Donor tags">Stanford Computer Science Department</note>
            </mods>
            EOF
        end

        it 'extracts the donor tags' do
          expect(solr_doc['donor_tags_ssim']).to contain_exactly 'Knowledge Systems Laboratory',
                                                                 'medical applications',
                                                                 'Publishing',
                                                                 'Stanford',
                                                                 'Stanford Computer Science Department'
        end
      end
    end # donor tags

    # rubocop:disable Metrics/LineLength
    describe '#add_folder_name' do
      let(:mods_note_plain) do
        Nokogiri::XML <<-EOF
          <mods xmlns="#{Mods::MODS_NS}">
            <note>#{example}</note>
          </mods>
        EOF
      end
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
          let(:example) { example }
          context 'in preferred citation note' do
            before do
              allow(r).to receive(:mods).and_return(mods_note_preferred_citation)
              subject.send(:add_folder_name, sdb, solr_doc)
            end
            it "has the expected folder name '#{expected}'" do
              expect(solr_doc['folder_name_ssi']).to eq expected
            end
          end
          context 'in plain note' do
            before do
              allow(r).to receive(:mods).and_return(mods_note_plain)
              subject.send(:add_folder_name, sdb, solr_doc)
            end
            it 'does not have a folder name' do
              expect(solr_doc['folder_name_ssi']).to be_falsey
            end
          end
        end # for example
      end # each
    end # add_folder_name
    # rubocop:enable Metrics/LineLength

    describe '#add_general_notes' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_general_notes, sdb, solr_doc)
      end

      context 'no general notes, but other types of notes' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <note displayLabel="preferred citation">(not a document subtype)</note>
              <note displayLabel="Document subtype">memorandums</note>
              <note displayLabel="Donor tags">Knowledge Systems Laboratory</note>
            </mods>
            EOF
        end

        it 'is blank' do
          expect(solr_doc['general_notes_ssim']).to be_blank
        end
      end

      context 'ignore extra notes' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <note displayLabel="Document subtype">memorandums</note>
              <note>a generic note</note>
            </mods>
            EOF
        end

        it 'extracts the doc subtypes' do
          expect(solr_doc['general_notes_ssim']).to contain_exactly 'a generic note'
        end
      end
    end # general notes
  end # feigbenbaum specific fields concern

  context 'StanfordMods concern' do
    describe '#add_author_no_collector' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_author_no_collector, sdb, solr_doc)
      end
      let(:name) { 'Macro Hamster' }
      let(:mods) do
        Nokogiri::XML <<-EOF
          <mods xmlns="#{Mods::MODS_NS}">
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
          </mods>
          EOF
      end
      it 'populates author_no_collector_ssim field in solr doc' do
        expect(solr_doc['author_no_collector_ssim']).to eq [name]
      end
      it 'calls non_collector_person_authors on Stanford::Mods::Record object' do
        expect(sdb.smods_rec).to receive(:non_collector_person_authors)
        subject.send(:add_author_no_collector, sdb, solr_doc)
      end
    end

    describe '#add_box' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_box, sdb, solr_doc)
      end
      context 'with a record without a box' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
            </mods>
          EOF
        end

        it 'is blank' do
          expect(solr_doc['box_ssi']).to be_blank
        end
      end
      context 'with a record with a box' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <location>
                <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
              </location>
            </mods>
          EOF
        end

        it 'extracts the box' do
          expect(solr_doc['box_ssi']).to eq('10')
        end
      end
    end # add_box

    describe '#add_collector' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_collector, sdb, solr_doc)
      end
      let(:name) { 'Macro Hamster' }
      let(:mods) do
        Nokogiri::XML <<-EOF
          <mods xmlns="#{Mods::MODS_NS}">
            <name type="personal">
              <namePart>#{name}</namePart>
              <role>
                <roleTerm type="code" authority="marcrelator">col</roleTerm>
              </role>
            </name>
          </mods>
          EOF
      end
      it 'populates collector_ssim field in solr doc' do
        expect(solr_doc['collector_ssim']).to eq [name]
      end
      it 'calls collectors_w_dates on Stanford::Mods::Record object' do
        expect(sdb.smods_rec).to receive(:collectors_w_dates)
        subject.send(:add_collector, sdb, solr_doc)
      end
    end

    describe '#add_coordinates' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_coordinates, sdb, solr_doc)
      end
      context 'with a record without coordinates' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
            </mods>
          EOF
        end

        it 'is blank' do
          expect(solr_doc['coordinates_tesim']).to be_blank
        end
      end
      context 'with a record with coordinates' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <subject>
                <cartographics>
                  <scale>Scale 1:500,000</scale>
                  <coordinates>(W16°--E28°/N13°--S15°).</coordinates>
                </cartographics>
              </subject>
            </mods>
          EOF
        end

        it 'extracts the coordinates' do
          expect(solr_doc['coordinates_tesim']).to eq(['(W16°--E28°/N13°--S15°).'])
        end
      end
    end # add_coordinates

    describe '#add_folder' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_folder, sdb, solr_doc)
      end
      context 'with a record without a folder' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
            </mods>
          EOF
        end

        it 'is blank' do
          expect(solr_doc['folder_ssi']).to be_blank
        end
      end
      context 'with a record with a folder' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <location>
                <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
              </location>
            </mods>
          EOF
        end

        it 'extracts the folder' do
          expect(solr_doc['folder_ssi']).to eq('8')
        end
      end
    end # add_folder

    describe '#add_genre' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_genre, sdb, solr_doc)
      end

      context 'with a record without a genre' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
            </mods>
            EOF
        end

        it 'is blank' do
          expect(solr_doc['genre_ssim']).to be_blank
        end
      end

      context 'with a record with a genre' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <genre authority="aat" valueURI="http://vocab.getty.edu/aat/300028579">manuscripts for publication</genre>
            </mods>
            EOF
        end

        it 'extracts the genre' do
          expect(solr_doc['genre_ssim']).to contain_exactly 'manuscripts for publication'
        end
      end
    end

    describe '#add_location' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_location, sdb, solr_doc)
      end
      context 'with a record without a location' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
            </mods>
          EOF
        end

        it 'is blank' do
          expect(solr_doc['location_ssi']).to be_blank
        end
      end
      context 'with a record with a location' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <location>
                <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
              </location>
            </mods>
          EOF
        end

        it 'extracts the location' do
          expect(solr_doc['location_ssi']).to eq('Series 1, Box 10, Folder 8')
        end
      end
    end # add_location

    describe '#add_point_bbox' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_point_bbox, sdb, solr_doc)
      end
      context 'with a record without coordinates' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
            </mods>
          EOF
        end

        it 'is blank' do
          expect(solr_doc['point_bbox']).to be_blank
        end
      end
      context 'with a record with coordinates' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <subject>
                <cartographics>
                  <scale>Scale 1:500,000</scale>
                  <coordinates>(W16°--E28°/N13°--S15°).</coordinates>
                </cartographics>
              </subject>
            </mods>
          EOF
        end

        it 'extracts the point_bbox' do
          expect(solr_doc['point_bbox']).to eq(['-16.0 -15.0 28.0 13.0'])
        end
      end
    end # add_point_bbox

    describe '#add_series' do
      before do
        allow(r).to receive(:mods).and_return(mods)
        subject.send(:add_series, sdb, solr_doc)
      end
      context 'with a record without a series' do
        let(:mods) do
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
            </mods>
          EOF
        end

        it 'is blank' do
          expect(solr_doc['series_ssi']).to be_blank
        end
      end
      context 'with a record with a series' do
        let(:mods) do
          # e.g. from https://purl.stanford.edu/vw282gv1740
          Nokogiri::XML <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <location>
                <physicalLocation>Series 1, Box 10, Folder 8</physicalLocation>
              </location>
            </mods>
          EOF
        end

        it 'extracts the series' do
          expect(solr_doc['series_ssi']).to eq('1')
        end
      end
    end # add_series
  end # context StanfordMods concern

  # rubocop:disable Metrics/LineLength
  context 'Full Text Indexing concern' do
    describe '#add_object_full_text' do
      let(:full_text_solr_fname) { 'full_text_tesimv' }
      before do
        allow(sdb).to receive(:bare_druid).and_return(fake_druid)
      end
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
        allow(sdb).to receive(:public_xml).and_return(public_xml_with_feigenbaum_full_text)
        # don't actually attempt a call to the stacks
        allow(subject).to receive(:get_file_content).with(full_file_path).and_return(expected_text)
        subject.send(:add_object_full_text, sdb, solr_doc)
        expect(subject.object_level_full_text_urls(sdb)).to eq [full_file_path]
        expect(solr_doc[full_text_solr_fname]).to eq [expected_text]
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
        allow(sdb).to receive(:public_xml).and_return(public_xml_with_no_recognized_full_text)
        subject.send(:add_object_full_text, sdb, solr_doc)
        expect(subject.object_level_full_text_urls(sdb)).to eq []
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
        allow(sdb).to receive(:public_xml).and_return(public_xml_with_two_recognized_full_text_files)
        allow(subject).to receive(:get_file_content).with(full_file_path).and_return(expected_text)
        subject.send(:add_object_full_text, sdb, solr_doc)
        expect(subject.object_level_full_text_urls(sdb)).to eq [full_file_path, full_file_path]
        expect(solr_doc[full_text_solr_fname]).to eq [expected_text, expected_text] # same file twice in a 2 element array
      end
    end # add_object_full_text
  end # full text indexing concern
  # rubocop:enable Metrics/LineLength
end
