require 'spec_helper'

describe Spotlight::Dor::Indexer do
  subject { described_class.new }

  let(:fake_druid) { 'oo000oo0000' }
  let(:r) { Harvestdor::Indexer::Resource.new(double, fake_druid) }
  let(:sdb) { GDor::Indexer::SolrDocBuilder.new(r, Logger.new(StringIO.new)) }
  let(:solr_doc) { {} }
  let(:mods_loc_phys_loc) do
    Nokogiri::XML <<-EOF
      <mods xmlns="#{Mods::MODS_NS}">
        <location>
          <physicalLocation>#{example}</physicalLocation>
        </location>
      </mods>
    EOF
  end
  let(:mods_rel_item_loc_phys_loc) do
    Nokogiri::XML <<-EOF
      <mods xmlns="#{Mods::MODS_NS}">
        <relatedItem>
          <location>
            <physicalLocation>#{example}</physicalLocation>
          </location>
        </relatedItem>
      </mods>
    EOF
  end

  before do
    allow(r).to receive(:harvestdor_client)
    i = Harvestdor::Indexer.new
    i.logger.level = Logger::WARN
    allow(r).to receive(:indexer).and_return i
  end

  describe '#add_series' do
    # example string as key, expected series name as value
    {
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101': '2005-101',
      'Call Number: SC0340, Accession 2005-101, Box : 39, Folder: 9': '2005-101',
      'Call Number: SC0340, Accession 2005-101, Box: 2, Folder: 3': '2005-101',
      'Call Number: SC0340, Accession: 1986-052': '1986-052',
      'Call Number: SC0340, Accession: 1986-052, Box 3 Folder 38': '1986-052',
      'Call Number: SC0340, Accession: 2005-101, Box : 50, Folder: 31': '2005-101',
      'Call Number: SC0340, Accession: 1986-052, Box: 5, Folder: 1': '1986-052',
      'SC0340, Accession 1986-052': '1986-052',
      'SC0340, Accession 2005-101, Box 18': '2005-101',
      'Call Number: SC0340, Accession 2005-101, Box: 42A, Folder: 24': '2005-101',
      'Call Number: SC0340, Accession: 1986-052, Box: 42A, Folder: 59': '1986-052',
      'SC0340': nil,
      'SC0340, 1986-052, Box 18': nil,
      'Stanford University. Libraries. Department of Special Collections and University Archives': nil,
      # shpc (actually in <relatedItem><location><physicalLocation>)
      'Series Biographical Photographs | Box 42 | Folder Abbot, Nathan': 'Biographical Photographs',
      'Series General Photographs | Box 42 | Folder Administration building--Outer Quad': 'General Photographs',
      # menuez
      'MSS Photo 451, Series 1, Box 32, Folder 11, Sleeve 32-11-2, Frame B32-F11-S2-6': '1',
      'Series 1, Box 10, Folder 8': '1',
      # fuller
      'Collection: M1090 , Series: 4 , Box: 5 , Folder: 10': '4',
      # hummel (actually in <relatedItem><location><physicalLocation>)
      'Box 42 | Folder 3': nil,
      'Flat-box 228 | Volume 1': nil
    }.each do |example, expected|
      describe "for example '#{example}'" do
        let(:example) { example }
        context 'in /location/physicalLocation' do
          before do
            i = Harvestdor::Indexer.new
            i.logger.level = Logger::WARN
            allow(r).to receive(:indexer).and_return(i)
            allow(r).to receive(:mods).and_return(mods_loc_phys_loc)
            subject.send(:add_series, sdb, solr_doc)
          end
          it "has the expected series name '#{expected}'" do
            expect(solr_doc['series_ssi']).to eq expected
          end
        end
        context 'in /relatedItem/location/physicalLocation' do
          before do
            allow(r).to receive(:mods).and_return(mods_rel_item_loc_phys_loc)
            subject.send(:add_series, sdb, solr_doc)
          end
          it "has the expected series name '#{expected}'" do
            expect(solr_doc['series_ssi']).to eq expected
          end
        end
      end # for example
    end # each
  end # add_series

  describe "#add_box" do
    # example string as key, expected box name as value
    {
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101, Box : 1, Folder: 1': '1',
      'Call Number: SC0340, Accession 2005-101, Box: 39, Folder: 9': '39',
      'Call Number: SC0340, Accession: 1986-052, Box 3 Folder 38': '3',
      'Call Number: SC0340, Accession: 2005-101, Box : 50, Folder: 31': '50',
      'Call Number: SC0340, Accession: 1986-052, Box: 5, Folder: 1': '5',
      'SC0340, 1986-052, Box 18': '18',
      'SC0340, Accession 2005-101, Box 18': '18',
      'Call Number: SC0340, Accession 2005-101, Box: 42A, Folder: 24': '42A',
      'Call Number: SC0340, Accession: 1986-052, Box: 42A, Folder: 59': '42A',
      'Call Number: SC0340, Accession 2005-101': nil,
      'Call Number: SC0340, Accession: 1986-052': nil,
      'SC0340': nil,
      'SC0340, Accession 1986-052': nil,
      'Stanford University. Libraries. Department of Special Collections and University Archives': nil,
      # shpc (actually in <relatedItem><location><physicalLocation>)
      'Series Biographical Photographs | Box 42 | Folder Abbot, Nathan': '42',
      'Series General Photographs | Box 42 | Folder Administration building--Outer Quad': '42',
      # menuez
      'MSS Photo 451, Series 1, Box 32, Folder 11, Sleeve 32-11-2, Frame B32-F11-S2-6': '32',
      'Series 1, Box 10, Folder 8': '10',
      # fuller
      'Collection: M1090 , Series: 1 , Box: 5 , Folder: 42': '5',
      # hummel (actually in <relatedItem><location><physicalLocation>)
      'Box 42 | Folder 3': '42',
      'Flat-box 228 | Volume 1': '228'
    }.each do |example, expected|
      describe "for example '#{example}'" do
        let(:example) { example }
        context 'in /location/physicalLocation' do
          before do
            i = Harvestdor::Indexer.new
            i.logger.level = Logger::WARN
            allow(r).to receive(:indexer).and_return(i)
            allow(r).to receive(:mods).and_return(mods_loc_phys_loc)
            subject.send(:add_box, sdb, solr_doc)
          end
          it "has the expected box name '#{expected}'" do
            expect(solr_doc['box_ssi']).to eq expected
          end
        end
        context 'in /relatedItem/location/physicalLocation' do
          before do
            allow(r).to receive(:mods).and_return(mods_rel_item_loc_phys_loc)
            subject.send(:add_box, sdb, solr_doc)
          end
          it "has the expected box name '#{expected}'" do
            expect(solr_doc['box_ssi']).to eq expected
          end
        end
      end # for example
    end # each
  end # add_box

  describe '#add_folder' do
    # example string as key, expected folder name as value
    {
      # feigenbaum
      'Call Number: SC0340, Accession 2005-101, Box : 1, Folder: 42': '42',
      'Call Number: SC0340, Accession 2005-101, Box: 2, Folder: 42': '42',
      'Call Number: SC0340, Accession: 1986-052, Box 3 Folder 42': '42',
      'Call Number: SC0340, Accession: 2005-101, Box : 4, Folder: 42': '42',
      'Call Number: SC0340, Accession: 1986-052, Box: 5, Folder: 42': '42',
      'Call Number: SC0340, Accession 2005-101, Box: 4A, Folder: 42': '42',
      'Call Number: SC0340, Accession: 1986-052, Box: 5A, Folder: 42': '42',
      'Call Number: SC0340, Accession 2005-101': nil,
      'Call Number: SC0340, Accession: 1986-052': nil,
      'SC0340': nil,
      'SC0340, 1986-052, Box 18': nil,
      'SC0340, Accession 2005-101': nil,
      'SC0340, Accession 2005-101, Box 18': nil,
      'Stanford University. Libraries. Department of Special Collections and University Archives': nil,
      # menuez
      'MSS Photo 451, Series 1, Box 32, Folder 42, Sleeve 32-11-2, Frame B32-F11-S2-6': '42',
      'Series 1, Box 10, Folder 42': '42',
      # fuller
      'Collection: M1090 , Series: 4 , Box: 5 , Folder: 42': '42',
      # hummel (actually in <relatedItem><location><physicalLocation>)
      'Box 1 | Folder 42': '42',
      'Flat-box 228 | Volume 1': nil,
      # shpc (actually in <relatedItem><location><physicalLocation>)
      'Series Biographical Photographs | Box 1 | Folder Abbot, Nathan': 'Abbot, Nathan',
      'Series General Photographs | Box 1 | Folder Administration building--Outer Quad': 'Administration building--Outer Quad'
    }.each do |example, expected|
      describe "for example '#{example}'" do
        let(:example) { example }
        context 'in /location/physicalLocation' do
          before do
            i = Harvestdor::Indexer.new
            i.logger.level = Logger::WARN
            allow(r).to receive(:indexer).and_return(i)
            allow(r).to receive(:mods).and_return(mods_loc_phys_loc)
            subject.send(:add_folder, sdb, solr_doc)
          end
          it "has the expected folder name '#{expected}'" do
            expect(solr_doc['folder_ssi']).to eq expected
          end
        end
        context 'in /relatedItem/location/physicalLocation' do
          before do
            allow(r).to receive(:mods).and_return(mods_rel_item_loc_phys_loc)
            subject.send(:add_folder, sdb, solr_doc)
          end
          it "has the expected folder name '#{expected}'" do
            expect(solr_doc['folder_ssi']).to eq expected
          end
        end
      end # for example
    end # each
  end # add_folder
end
