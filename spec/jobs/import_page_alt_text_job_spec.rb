# frozen_string_literal: true

require 'rails_helper'

describe ImportPageAltTextJob do
  let(:job) { described_class.new }
  let(:csv_path) { '/path/to/alt_text.csv' }
  let(:dry_run) { false }
  let(:exhibit) { create(:exhibit, title: 'Test Exhibit', slug: 'test-exhibit') }
  let(:druid_item_id) { 'cy496ky1984' }
  let(:another_druid) { 'wj977xb5593' }
  let(:item_id) { 'item_0' }
  let(:solr_block_data) do
    {
      type: 'solr_documents',
      data: {
        format: 'html',
        item: { item_id => { 'id' => druid_item_id, 'alt_text' => 'Original alt text', 'display' => 'true' },
                'item_1' => { 'id' => another_druid, 'alt_text' => 'Original alt text', 'display' => 'true' } }
      }
    }
  end
  let(:uploaded_images_data) do
    {
      type: 'uploaded_items',
      data: {
        format: 'html',
        item: { 'file_0' => {
          'id' => 'st-block-8-1748552059346-raw', 'alt_text' => 'Original uploaded image alt text',
          'display' => 'true',
          'url' => '/uploads/spotlight/attachment/file/9287/SC0487_1995_040_B6_UGS22_Report_01_Page_1.jpg'
        } }
      }
    }
  end
  let(:feature_page) { create(:feature_page, exhibit:, title: 'Test Page', slug: 'test-page') }
  let(:ai_description) { 'AI generated description' }
  let(:image_url) { 'https://stacks.stanford.edu/image/iiif/cy496ky1984%2F36105115938321_0002/full/!400,400/0/default.jpg' }
  let(:human_description) { '' }
  let(:not_useful) { '' }
  let(:useful_as_is) { '' }
  let(:partially_useful) { '' }
  let(:decorative) { '' }
  let(:csv_row) do
    {
      'Exhibit' => 'Test Exhibit',
      'Page URL' => 'http://example.com/test-exhibit/feature/test-page',
      'Image URL' => image_url,
      'AI Generated Description (gemini-2.0-flash)' => ai_description,
      'AI description NOT useful and new, accurate alt text must be created (mark with an "X" if so)' => not_useful,
      'AI description useful AS IS (mark with an "X" if so)' => useful_as_is,
      'AI description partially useful with EDITS NEEDED (mark with an "X" if so)' => partially_useful,
      'New OR edited description (when needed)' => human_description,
      'Image is DECORATIVE, no description required (mark with an "X" if so)' => decorative
    }
  end

  before do
    solr_block = SirTrevorRails::Blocks::SolrDocumentsBlock.from_hash(solr_block_data)
    uploaded_items_block = SirTrevorRails::Blocks::UploadedItemsBlock.from_hash(uploaded_images_data)
    feature_page.content = [solr_block, uploaded_items_block]
    feature_page.save!
    feature_page.reload
    allow(Spotlight::Exhibit).to receive(:find_by).with(title: 'Test Exhibit').and_return(exhibit)
    allow(CSV).to receive(:foreach).with(csv_path, headers: true).and_yield(csv_row)
    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:info)
  end

  describe '#perform' do
    context 'when image is marked as decorative' do
      let(:decorative) { 'X' }

      it 'marks the item alt text as decorative' do
        job.perform(csv_path:)
        updated_page = Spotlight::FeaturePage.find(feature_page.id)
        updated_item = updated_page.content.first.item[item_id]
        expect(updated_item['decorative']).to eq('on')
        expect(updated_item['alt_text']).to eq('')
        expect(updated_item['alt_text_backup']).to eq('Original alt text')
      end
    end

    context 'when AI description is marked as useful as-is' do
      let(:useful_as_is) { 'x' }
      let(:ai_description) { 'This is a useful AI description' }

      it 'updates the item alt text to use the AI-generated alt text' do
        job.perform(csv_path:, dry_run:)
        updated_page = Spotlight::FeaturePage.find(feature_page.id)
        updated_item = updated_page.content.first.item[item_id]
        expect(updated_item).not_to have_key('decorative')
        expect(updated_item['alt_text']).to eq('This is a useful AI description')
      end
    end

    context 'when AI description is marked partially useful and human edits are provided' do
      let(:partially_useful) { 'X' }
      let(:human_description) { 'This is an improved human-edited description' }

      it 'updates the item alt text to use the human-edited description' do
        job.perform(csv_path:, dry_run:)
        updated_page = Spotlight::FeaturePage.find(feature_page.id)
        updated_item = updated_page.content.first.item[item_id]
        expect(updated_item).not_to have_key('decorative')
        expect(updated_item['alt_text']).to eq('This is an improved human-edited description')
      end
    end

    context 'when AI description is marked as not useful and human description is provided' do
      let(:not_useful) { 'X' }
      let(:human_description) { 'This is a human-written description' }

      it 'updates the item alt text to use the human-written description' do
        job.perform(csv_path:, dry_run:)
        updated_page = Spotlight::FeaturePage.find(feature_page.id)
        updated_item = updated_page.content.first.item[item_id]
        expect(updated_item).not_to have_key('decorative')
        expect(updated_item['alt_text']).to eq('This is a human-written description')
      end
    end

    context 'when a row has no alt text selection' do
      let(:not_useful) { '' }
      let(:useful_as_is) { '' }
      let(:partially_useful) { '' }
      let(:decorative) { '' }

      it 'logs an error and skips the row' do
        job.perform(csv_path:, dry_run:)
        unchanged_page = Spotlight::FeaturePage.find(feature_page.id)
        unchanged_item = unchanged_page.content.first.item[item_id]
        expect(unchanged_item['alt_text']).to eq('Original alt text')
        expect(Rails.logger).to have_received(:error).with(/Skipping invalid row/)
      end
    end

    context 'when a row has a non-decorative selection but empty alt text' do
      let(:partially_useful) { 'x' }
      let(:human_description) { '' }

      it 'logs an error and skips the row' do
        job.perform(csv_path:, dry_run:)
        unchanged_page = Spotlight::FeaturePage.find(feature_page.id)
        unchanged_item = unchanged_page.content.first.item[item_id]
        expect(unchanged_item['alt_text']).to eq('Original alt text')
        expect(Rails.logger).to have_received(:error).with(/Skipping invalid row/)
      end
    end

    context 'when the image is an uploaded attachment, not a druid' do
      let(:image_url) { 'https://exhibits.stanford.edu/uploads/spotlight/attachment/file/9287/SC0487_1995_040_B6_UGS22_Report_01_Page_1.jpg' }
      let(:ai_description) { 'This is a useful AI description' }
      let(:useful_as_is) { 'x' }

      it 'updates the alt text' do
        job.perform(csv_path:, dry_run:)
        updated_page = Spotlight::FeaturePage.find(feature_page.id)
        updated_item = updated_page.content.last.item['file_0']
        expect(updated_item).not_to have_key('decorative')
        expect(updated_item['alt_text']).to eq('This is a useful AI description')
      end
    end

    context 'when a matching image is not found in the page' do
      let(:ai_description) { 'This is a useful AI description' }
      let(:useful_as_is) { 'x' }
      let(:image_url) { 'https://stacks.stanford.edu/image/iiif/NONMATCHINGDRUID%2F36105115938321_0002/full/!400,400/0/default.jpg' }

      it 'logs an error and skips the row' do
        job.perform(csv_path:, dry_run:)
        unchanged_page = Spotlight::FeaturePage.find(feature_page.id)
        unchanged_item = unchanged_page.content.first.item[item_id]
        expect(unchanged_item['alt_text']).to eq('Original alt text')
        expect(Rails.logger).to have_received(:error).with(/Failed to find/)
      end
    end

    context 'when the row image is used by more than one item in the page' do
      let(:ai_description) { 'This is a useful AI description' }
      let(:useful_as_is) { 'x' }
      let(:another_druid) { druid_item_id }

      it 'logs an error and skips the row' do
        job.perform(csv_path:, dry_run:)
        unchanged_page = Spotlight::FeaturePage.find(feature_page.id)
        unchanged_item = unchanged_page.content.first.item[item_id]
        expect(unchanged_item['alt_text']).to eq('Original alt text')
        expect(Rails.logger).to have_received(:error).with(/Ambiguous match/)
      end
    end

    context 'when the row has multiple alt text selections' do
      let(:not_useful) { 'X' }
      let(:useful_as_is) { 'X' }

      it 'logs an error and skips the row' do
        job.perform(csv_path:, dry_run:)
        unchanged_page = Spotlight::FeaturePage.find(feature_page.id)
        unchanged_item = unchanged_page.content.first.item[item_id]
        expect(unchanged_item['alt_text']).to eq('Original alt text')
        expect(Rails.logger).to have_received(:error).with(/Skipping invalid row/)
      end
    end

    context 'when a page has no content' do
      before do
        feature_page.content = nil
        feature_page.save!
        feature_page.reload
      end

      let(:partially_useful) { 'X' }
      let(:human_description) { 'This is an improved human-edited description' }

      it 'logs an error and skips the row' do
        job.perform(csv_path:, dry_run:)
        expect(Rails.logger).to have_received(:error).with(/Failed to find/)
      end
    end

    context 'when performing a dry run with a valid row' do
      let(:dry_run) { true }
      let(:partially_useful) { 'X' }
      let(:human_description) { 'This is an improved human-edited description' }

      it 'does not update the item' do
        job.perform(csv_path:, dry_run:)
        unchanged_page = Spotlight::FeaturePage.find(feature_page.id)
        unchanged_item = unchanged_page.content.first.item[item_id]
        expect(unchanged_item['alt_text']).to eq('Original alt text')
        expect(Rails.logger).to have_received(:info).with(/Updated alt text for image/)
      end
    end
  end
end
