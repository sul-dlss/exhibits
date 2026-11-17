# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IndexRelatedContentJob do
  describe '#perform' do
    let(:exhibit) { create(:exhibit) }
    let(:harvester) { DorHarvester.new(exhibit: exhibit) }
    let(:enqueuer) { instance_double(IiifCanvasIndexer, index_canvases: []) }

    it 'indexes the canvases for the druid' do
      allow(IiifCanvasIndexer).to receive(:new).and_return(enqueuer)
      subject.perform(harvester, 'abc123')
      expect(IiifCanvasIndexer).to have_received(:new).with(exhibit, 'abc123')
      expect(enqueuer).to have_received(:index_canvases)
    end
  end
end
