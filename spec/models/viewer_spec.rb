# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Viewer do
  let(:viewer) { create(:viewer) }

  it 'belongs to an exhibit' do
    expect(described_class.reflect_on_association(:exhibit).macro).to eq :belongs_to
  end

  describe '#mirador?' do
    it 'is true for the mirador viewer types' do
      expect(described_class.new(viewer_type: 'mirador3')).to be_mirador
      expect(described_class.new(viewer_type: 'mirador')).to be_mirador
    end

    it 'is false for sul-embed or an unset viewer type' do
      expect(described_class.new(viewer_type: 'sul-embed')).not_to be_mirador
      expect(described_class.new(viewer_type: nil)).not_to be_mirador
    end
  end
end
