# frozen_string_literal: true

require 'rails_helper'

describe MetadataHelper, type: :helper do
  describe '#mods_value_white_space_splitter!' do
    let(:mods_values) do
      ModsDisplay::Values.new(
        label: 'Abstract:',
        values: ["Tariffs and Trade.\r\n\r\nThe purpose ofGATT secretariat.\r\n\r\nThe Bibliography"]
      )
    end

    it 'splits ModsDisplay::Values on embedded whitespace based off of bc777tp9978' do
      expect(helper.mods_value_white_space_splitter!(mods_values).values.length).to eq 5
    end
  end
end
