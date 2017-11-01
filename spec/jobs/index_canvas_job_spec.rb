# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IndexCanvasJob do
  describe '#perform' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:canvas_id) { 'https://dms-data.stanford.edu/data/manifests/Parker/fh878gz0315/canvas/canvas-521' }
    let(:canvas_file) { 'spec/fixtures/iiif/fh878gz0315-canvas-521.json' }
    let(:canvas_content) { File.read(canvas_file) }

    it 'Creates a CanvasResource' do
      expect do
        subject.perform(canvas_id, canvas_content, exhibit)
      end.to change { CanvasResource.count }.from(0).to(1)
    end
    it 'When existing, a new one is not created, but content is' do
      resource = CanvasResource.create(url: canvas_id, exhibit: exhibit)
      expect(resource.data).to eq({})
      expect do
        subject.perform(canvas_id, canvas_content, exhibit)
      end.not_to(change { CanvasResource.count })
      resource.reload
      expect(resource.data).to eq JSON.parse(canvas_content)
    end
  end
end
