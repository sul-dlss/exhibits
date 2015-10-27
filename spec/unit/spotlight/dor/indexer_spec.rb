require 'spec_helper'

describe Spotlight::Dor::Indexer do
  subject { described_class.new }

  let(:fake_druid) { 'oo000oo0000' }
  let(:r) { Harvestdor::Indexer::Resource.new(double, fake_druid) }
  let(:logger) { Logger.new(StringIO.new) }
  let(:sdb) { GDor::Indexer::SolrDocBuilder.new(r, logger) }
  let(:solr_doc) { {} }
  let(:smods_rec) { Stanford::Mods::Record.new }
  let(:mods_loc_phys_loc_start) { "<mods xmlns='#{Mods::MODS_NS}'><location><physicalLocation>" }
  let(:mods_loc_phys_loc_end) { '</physicalLocation></location></mods>' }
  let(:mods_rel_item_loc_phys_loc_start) { "<mods xmlns='#{Mods::MODS_NS}'><relatedItem><location><physicalLocation>" }
  let(:mods_rel_item_loc_phys_loc_end) { '</physicalLocation></location></relatedItem></mods>' }

  before do
    allow(r).to receive(:harvestdor_client)
  end

  describe '#add_series' do
    exemplars_based_on_feigenbaum = [
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101',
      'Call Number: SC0340, Accession 2005-101, Box : 39, Folder: 9',
      'Call Number: SC0340, Accession: 2005-101',
      'Call Number: SC0340, Accession: 2005-101, Box : 50, Folder: 31',
      'SC0340, Accession 2005-101',
      'SC0340, Accession 2005-101, Box 18'
    ]
    exemplars_based_on_feigenbaum.each do |example|
      it "parses series number from physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_series, sdb, solr_doc)
        expect(solr_doc['series_ssim']).to match_array ['2005-101']
      end
      it "parses series number from relItem physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{example}#{mods_rel_item_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_series, sdb, solr_doc)
        expect(solr_doc['series_ssim']).to match_array ['2005-101']
      end
    end

    numeric_exemplars_based_on_actual_data = [
      # menuez
      'MSS Photo 451, Series 1, Box 32, Folder 11, Sleeve 32-11-2, Frame B32-F11-S2-6',
      'Series 1, Box 10, Folder 8',
      # fuller
      'Collection: M1090 , Series: 1 , Box: 5 , Folder: 42',
    ]
    numeric_exemplars_based_on_actual_data.each do |example|
      it "parses series number from physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_series, sdb, solr_doc)
        expect(solr_doc['series_ssim']).to match_array ['1']
      end
      it "parses series number from relItem physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{example}#{mods_rel_item_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_series, sdb, solr_doc)
        expect(solr_doc['series_ssim']).to match_array ['1']
      end
    end

    # shpc
    shpc1 = 'Series Biographical Photographs | Box 1 | Folder Abbot, Nathan'
    it "parses series name from '#{shpc1}'" do
      ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{shpc1}#{mods_rel_item_loc_phys_loc_end}")
      allow(r).to receive(:mods).and_return(ng_mods)
      subject.send(:add_series, sdb, solr_doc)
      expect(solr_doc['series_ssim']).to match_array ['Biographical Photographs']
    end
    shpc2 = 'Series General Photographs | Box 1 | Folder Administration building--Outer Quad'
    it "parses series name from '#{shpc2}'" do
      ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{shpc2}#{mods_rel_item_loc_phys_loc_end}")
      allow(r).to receive(:mods).and_return(ng_mods)
      subject.send(:add_series, sdb, solr_doc)
      expect(solr_doc['series_ssim']).to match_array ['General Photographs']
    end

    unparsable_exemplars_based_on_actual_data = [
      # feigenbaum
      'SC0340, 1986-052, Box 18',
      'SC0340',
      'Stanford University. Libraries. Department of Special Collections and University Archives'
    ]
    unparsable_exemplars_based_on_actual_data.each do |example|
      it "does not parse series number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_series, sdb, solr_doc)
        expect(solr_doc).not_to include 'series_ssim'
      end
    end
  end # add_series

  describe "#add_box" do
    parsable_exemplars_based_on_actual_data = [
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101, Box : 42, Folder: 1',
      'Call Number: SC0340, Accession 2005-101, Box: 42, Folder: 3',
      'Call Number: SC0340, Accession: 1986-052, Box 42 Folder 38',
      'Call Number: SC0340, Accession: 2005-101, Box : 42, Folder: 20',
      'Call Number: SC0340, Accession: 1986-052, Box: 42, Folder: 1',
      'SC0340, 1986-052, Box 42',
      'SC0340, Accession 1986-052, Box 42',
      # shpc
      'Series Biographical Photographs | Box 42 | Folder Abbot, Nathan',
      'Series General Photographs | Box 42 | Folder Administration building--Outer Quad',
      # menuez
      'MSS Photo 451, Series 1, Box 42, Folder 11, Sleeve 32-11-2, Frame B32-F11-S2-6',
      'Series 1, Box 42, Folder 8',
      # fuller
      'Collection: M1090 , Series: 4 , Box: 42 , Folder: 10',
      # hummel (actually in <relatedItem><location><physicalLocation>)
      'Box 42 | Folder 3',
      'Flat-box 42 | Volume 1'
    ]
    parsable_exemplars_based_on_actual_data.each do |example|
      it "parses box number from physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_box, sdb, solr_doc)
        expect(solr_doc['box_ssim']).to match_array ['42']
      end
      it "parses box number from relItem physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{example}#{mods_rel_item_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_box, sdb, solr_doc)
        expect(solr_doc['box_ssim']).to match_array ['42']
      end
    end
    boxes_with_letters = [
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101, Box: 42A, Folder: 24',
      'Call Number: SC0340, Accession: 1986-052, Box: 42A, Folder: 59'
    ]
    boxes_with_letters.each do |example|
      it "parses box number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_box, sdb, solr_doc)
        expect(solr_doc['box_ssim']).to match_array ['42A']
      end
    end

    unparsable_exemplars_based_on_actual_data = [
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101',
      'Call Number: SC0340, Accession: 1986-052',
      'SC0340',
      'SC0340, Accession 1986-052',
      'Stanford University. Libraries. Department of Special Collections and University Archives',
    ]
    unparsable_exemplars_based_on_actual_data.each do |example|
      it "does not parse box number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_box, sdb, solr_doc)
        expect(solr_doc).not_to include 'box_ssim'
      end
    end
  end # add_box

  describe '#add_folder' do
    parsable_exemplars_based_on_actual_data = [
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101, Box : 1, Folder: 42',
      'Call Number: SC0340, Accession 2005-101, Box: 2, Folder: 42',
      'Call Number: SC0340, Accession: 1986-052, Box 3 Folder 42',
      'Call Number: SC0340, Accession: 2005-101, Box : 4, Folder: 42',
      'Call Number: SC0340, Accession: 1986-052, Box: 5, Folder: 42',
      'Call Number: SC0340, Accession 2005-101, Box: 4A, Folder: 42',
      'Call Number: SC0340, Accession: 1986-052, Box: 5A, Folder: 42',
      # menuez
      'MSS Photo 451, Series 1, Box 32, Folder 42, Sleeve 32-11-2, Frame B32-F11-S2-6',
      'Series 1, Box 10, Folder 42',
      # fuller
      'Collection: M1090 , Series: 4 , Box: 5 , Folder: 42',
      # hummel
      'Box 1 | Folder 42'
    ]
    parsable_exemplars_based_on_actual_data.each do |example|
      it "parses folder number from physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_folder, sdb, solr_doc)
        expect(solr_doc['folder_ssim']).to match_array ['42']
      end
      it "parses folder number from relItem physLoc '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{example}#{mods_rel_item_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_folder, sdb, solr_doc)
        expect(solr_doc['folder_ssim']).to match_array ['42']
      end
    end

    # shpc
    shpc1 = 'Series Biographical Photographs | Box 1 | Folder Abbot, Nathan'
    it "parses folder name from '#{shpc1}'" do
      ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{shpc1}#{mods_rel_item_loc_phys_loc_end}")
      allow(r).to receive(:mods).and_return(ng_mods)
      subject.send(:add_folder, sdb, solr_doc)
      expect(solr_doc['folder_ssim']).to match_array ['Abbot, Nathan']
    end
    shpc2 = 'Series General Photographs | Box 1 | Folder Administration building--Outer Quad'
    it "parses folder name from '#{shpc2}'" do
      ng_mods = Nokogiri::XML("#{mods_rel_item_loc_phys_loc_start}#{shpc2}#{mods_rel_item_loc_phys_loc_end}")
      allow(r).to receive(:mods).and_return(ng_mods)
      subject.send(:add_folder, sdb, solr_doc)
      expect(solr_doc['folder_ssim']).to match_array ['Administration building--Outer Quad']
    end

    unparsable_exemplars_based_on_actual_data = [
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101',
      'Call Number: SC0340, Accession: 1986-052',
      'SC0340',
      'SC0340, 1986-052, Box 18',
      'SC0340, Accession 2005-101',
      'SC0340, Accession 2005-101, Box 18',
      'Stanford University. Libraries. Department of Special Collections and University Archives',
      # hummel (actually in <relatedItem><location><physicalLocation>)
      'Flat-box 228 | Volume 1'
    ]
    unparsable_exemplars_based_on_actual_data.each do |example|
      it "does not parse folder number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_loc_phys_loc_start}#{example}#{mods_loc_phys_loc_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_folder, sdb, solr_doc)
        expect(solr_doc).not_to include 'folder_ssim'
      end
    end
  end # add_folder
end
