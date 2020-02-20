# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchAcrossHelper, type: :helper do
  describe '#search_without_group' do
    let(:search_state) do
      instance_double(
        'Blacklight::SearchState',
        params_for_search: { group: true }
      )
    end

    it 'removes the group key/value' do
      expect(helper).to receive_messages(
        search_state: search_state
      )
      expect(helper.search_without_group).to eq({})
    end
  end

  describe '#search_with_group' do
    let(:search_state) do
      instance_double(
        'Blacklight::SearchState',
        params_for_search: {}
      )
    end

    it 'removes the group key/value' do
      expect(helper).to receive_messages(
        search_state: search_state
      )
      expect(helper.search_with_group).to eq group: true
    end
  end
end
