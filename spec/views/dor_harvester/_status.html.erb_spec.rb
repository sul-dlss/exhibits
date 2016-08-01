require 'rails_helper'

RSpec.describe 'dor_harvester/_status.html.erb', type: :view do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:harvester) { DorHarvester.new(druid_list: '', exhibit: exhibit) }

  context 'with status information' do
    before do
      harvester.on_success(instance_double(Harvestdor::Indexer::Resource, bare_druid: 'okdruid'))
      harvester.on_error(instance_double(Harvestdor::Indexer::Resource, bare_druid: 'baddruid'), 'broken')
      harvester.collections['collectiondruid'] = { size: 52 }
    end

    it 'displays the object status' do
      render partial: 'dor_harvester/status', locals: { harvester: harvester }
      expect(rendered).to have_content('Object druids')
      expect(rendered).to have_content 'okdruid Published'
      expect(rendered).to have_selector '.danger', text: /baddruid\s+broken/
    end

    it 'displays the collection status' do
      render partial: 'dor_harvester/status', locals: { harvester: harvester }
      expect(rendered).to have_content('Collection druids')
      expect(rendered).to have_content 'collectiondruid 52'
    end
  end

  context 'without status information' do
    it 'displays an empty status' do
      render partial: 'dor_harvester/status', locals: { harvester: harvester }
      expect(rendered).not_to have_selector '#sdr-status-inner-items'
      expect(rendered).not_to have_selector '#sdr-status-inner-collections'
    end
  end
end
