# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::MapsHelperOverride, type: :helper do
  let(:exhibit) { create(:exhibit) }

  before do
    helper.extend(Module.new do
      def current_exhibit; end

      def blacklight_config; end
    end)
    allow(helper).to receive(:current_exhibit).and_return(exhibit)
    allow(helper).to receive(:blacklight_config).and_return(exhibit.blacklight_config)
  end

  describe '#document_path' do
    it 'is a parameterized path for documents' do
      expect(helper.send(:document_path)).to eq "/#{exhibit.slug}/catalog/{id}"
    end
  end
end
