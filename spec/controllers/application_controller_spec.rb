# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController do
  describe '#feature_flags' do
    it 'initializes a FeatureFlags object' do
      expect(described_class.new.feature_flags).to be_a FeatureFlags
    end

    it 'sets current_exhibit context in the FeatureFlags object' do
      controller = described_class.new
      allow(controller).to receive(:current_exhibit).and_return(create(:exhibit, slug: 'test-flag-exhibit-slug'))

      expect(controller.feature_flags.test_thing?).to be true
    end
  end
end
