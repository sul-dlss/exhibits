# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IndexRelatedContentJob do
  describe '#perform' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:harvester) { DorHarvester.new(exhibit: exhibit) }
    let(:enqueuer) { instance_double(IiifCanvasIndexerEnqueuer, enqueue_jobs: []) }

    it do
      allow(IiifCanvasIndexerEnqueuer).to receive(:new).and_return(enqueuer)
      subject.perform(harvester, 'abc123')
    end
  end
end
