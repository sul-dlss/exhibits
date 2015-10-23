require 'spec_helper'

describe Spotlight::Dor::Indexer do
  subject { described_class.new }

  let(:fake_druid) { 'oo000oo0000' }
  let(:r) { Harvestdor::Indexer::Resource.new(double, fake_druid) }
  let(:logger) { Logger.new(StringIO.new) }
  let(:sdb) { GDor::Indexer::SolrDocBuilder.new(r, logger) }
  let(:solr_doc) { {} }
  let(:smods_rec) { Stanford::Mods::Record.new }

  before do
    allow(r).to receive(:harvestdor_client)
  end

  describe '#add_series' do
    let(:mods_start) { "<mods xmlns='#{Mods::MODS_NS}'><location><physicalLocation>" }
    let(:mods_end) { '</physicalLocation></location></mods>' }

    parsable_exemplars_based_on_actual_data = [
      'Call Number: SC0340, Accession 2005-101',
      'Call Number: SC0340, Accession 2005-101, Box : 39, Folder: 9',
      'Call Number: SC0340, Accession: 2005-101',
      'Call Number: SC0340, Accession: 2005-101, Box : 50, Folder: 31',
      'SC0340, Accession 2005-101',
      'SC0340, Accession 2005-101, Box 18'
    ]
    parsable_exemplars_based_on_actual_data.each do |example|
      it "parses series number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_start}#{example}#{mods_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_series, sdb, solr_doc)
        expect(solr_doc['series_ssim']).to match_array ['2005-101']
      end
    end

    unparsable_exemplars_based_on_actual_data = [
      'SC0340, 1986-052, Box 18',
      'SC0340',
      'Stanford University. Libraries. Department of Special Collections and University Archives'
    ]
    unparsable_exemplars_based_on_actual_data.each do |example|
      it "does not parse series number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_start}#{example}#{mods_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_series, sdb, solr_doc)
        expect(solr_doc).not_to include 'series_ssim'
      end
    end
  end # add_series

  describe "#add_box" do
    let(:mods_start) { "<mods xmlns='#{Mods::MODS_NS}'><location><physicalLocation>" }
    let(:mods_end) { '</physicalLocation></location></mods>' }

    parsable_exemplars_based_on_actual_data = [
      'Call Number: SC0340, Accession 2005-101, Box : 42, Folder: 1',
      'Call Number: SC0340, Accession 2005-101, Box: 42, Folder: 3',
      'Call Number: SC0340, Accession: 2005-101, Box : 42, Folder: 20',
      'Call Number: SC0340, Accession: 1986-052, Box: 42, Folder: 1',
      'SC0340, 1986-052, Box 42',
      'SC0340, Accession 1986-052, Box 42'
    ]
    parsable_exemplars_based_on_actual_data.each do |example|
      it "parses box number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_start}#{example}#{mods_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_box, sdb, solr_doc)
        expect(solr_doc['box_ssim']).to match_array ['42']
      end
    end
    boxes_with_letters = [
      'Call Number: SC0340, Accession 2005-101, Box: 42A, Folder: 24',
      'Call Number: SC0340, Accession: 1986-052, Box: 42A, Folder: 59',
    ]
    boxes_with_letters.each do |example|
      it "parses box number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_start}#{example}#{mods_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_box, sdb, solr_doc)
        expect(solr_doc['box_ssim']).to match_array ['42A']
      end
    end

    unparsable_exemplars_based_on_actual_data = [
      'Call Number: SC0340, Accession 2005-101',
      'Call Number: SC0340, Accession: 1986-052',
      'SC0340',
      'SC0340, Accession 1986-052',
      'Stanford University. Libraries. Department of Special Collections and University Archives'
    ]
    unparsable_exemplars_based_on_actual_data.each do |example|
      it "does not parse series number from '#{example}'" do
        ng_mods = Nokogiri::XML("#{mods_start}#{example}#{mods_end}")
        allow(r).to receive(:mods).and_return(ng_mods)
        subject.send(:add_box, sdb, solr_doc)
        expect(solr_doc).not_to include 'box_ssim'
      end
    end
  end
end
