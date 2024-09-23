# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatorContributorsFieldPresenter, type: :view do
  subject(:presenter) { described_class.new(request_context, document, field_config, options) }

  let(:request_context) { view }
  let(:document) do
    SolrDocument.new(id: 1, 'name_roles_ssim' => [
                       'Author|Doe, John',
                       'Editor|Smith, Bob',
                       '|Smith, Jane',
                       'Illustrator|Smith, Bob'
                     ])
  end
  let(:options) { {} }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:field_config) { blacklight_config.index_fields[field_name] }
  let(:field_name) { 'name_roles_ssim' }

  describe '#render' do
    subject(:result) { presenter.render }

    it 'reformats the roles to be more human-readable' do
      expect(result).to include 'Doe, John (Author)'
    end

    it 'de-duplicates the names' do
      expect(result).to include 'Smith, Bob (Editor, Illustrator)'
    end

    it 'omits the role when it is blank' do
      expect(result).to end_with 'Smith, Jane'
    end

    it 'preserves the order of the (first occurence of the) names' do
      expect(result).to eq 'Doe, John (Author), Smith, Bob (Editor, Illustrator), and Smith, Jane'
    end
  end
end
