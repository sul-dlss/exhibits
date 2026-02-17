# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaPhysicalLocation do
  subject(:physical_location) { described_class.new(cocina_record: CocinaDisplay::CocinaRecord.new(public_cocina)) }

  let(:public_cocina) { JSON.parse(File.read(File.join(FIXTURES_PATH, 'cocina/rk684yq9989.json'))) }

  describe '#box' do
    it 'returns the box location' do
      expect(physical_location.box).to eq('1')
    end
  end

  describe '#folder' do
    it 'returns the folder location' do
      expect(physical_location.folder).to eq('6')
    end
  end

  describe '#physical_location' do
    it 'returns the physical location string' do
      expect(physical_location.physical_location).to eq(
        'Call Number: SC0340, Accession: 1986-052, Box: 1, Folder: 6'
      )
    end
  end

  describe '#series' do
    it 'returns the series location' do
      expect(physical_location.series).to eq('1986-052')
    end
  end

  context 'where there is a physical location without a value' do
    let(:public_cocina) { JSON.parse(File.read(File.join(FIXTURES_PATH, 'cocina/kt278kc6873.json'))) }

    it 'returns nil for box' do
      expect(physical_location.box).to be_nil
    end
  end
end
