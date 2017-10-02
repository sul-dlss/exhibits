# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bibliography resource integration test', type: :feature do
  subject(:bibliograpy_resource) do
    BibliographyResource.new(
      bibtex_file: File.open(file).read, exhibit: exhibit
    )
  end

  let(:file) { 'spec/fixtures/bibliography/article.bib' }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:title_fields) do
    %w(title_display title_full_display title_uniform_search)
  end

  it 'can write the document to solr' do
    expect { bibliograpy_resource.reindex }.not_to raise_error
  end

  context 'to_solr' do
    subject(:document) do
      SolrDocument.new(bibliograpy_resource.document_builder.to_solr.first)
    end

    it 'has a doc id' do
      expect(document[:id]).to eq 'QTWBAWKX'
    end

    it 'is a reference document' do
      expect(document.reference?).to be_truthy
    end

    it 'has some titles' do
      title_fields.each do |field_name|
        expect(document[field_name]).to eq ['Quelques observations sur le porc-'\
          'épic et le hérisson dans la littérature et l’iconographie médiévale']
      end
    end

    it 'has an author' do
      expect(document['author_person_full_display']).to eq ['Wille, Clara']
    end

    it 'has publication title' do
      expect(document['pub_display']).to eq ['Reinardus. Yearbook of the International Reynard Society']
    end

    it 'has BibTeX' do
      expect(document.bibtex.to_s).to include '@article{http://zotero.org/groups/1051392/items/QTWBAWKX'
    end

    it 'has formatted bibliography in HTML' do
      expect(document.formatted_bibliography).to match(/^Wille, Clara/)
    end

    it 'has spotlight data' do
      expect(document).to include :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
    end
  end
  context 'with no title' do
    subject(:no_title) do
      BibliographyResource.new(
        bibtex_file: File.open('spec/fixtures/bibliography/notitle.bib').read, exhibit: exhibit
      )
    end

    it 'is skipped' do
      expect(no_title.document_builder.to_solr.first).to be_nil
    end
  end
  context 'with no author' do
    subject(:no_author) do
      BibliographyResource.new(
        bibtex_file: File.open('spec/fixtures/bibliography/noauthor.bib').read, exhibit: exhibit
      )
    end

    let(:document) { no_author.document_builder.to_solr.first }

    it 'is not skipped' do
      expect(document['author_person_full_display']).to be_nil
      title_fields.each do |field_name|
        expect(document).to include field_name
      end
    end
  end
  context 'with no keywords' do
    subject(:no_keywords) do
      BibliographyResource.new(
        bibtex_file: File.open('spec/fixtures/bibliography/nokeywords.bib').read, exhibit: exhibit
      )
    end

    it 'is skipped' do
      expect(no_keywords.document_builder.to_solr.first).to be_nil
    end
  end
  context 'with TeX-ified title' do
    subject(:document) do
      SolrDocument.new(bibliograpy_resource.document_builder.to_solr.first)
    end

    let(:file) { 'spec/fixtures/bibliography/texifiedtitle.bib' }

    before do
      allow(BibTeX.log).to receive(:warn).with(/Lexer: unbalanced braces at 210/)
    end

    it 'does not parse the BibTeX cleanly' do
      expect { document }.not_to raise_error
      expect(BibTeX.log).to have_received(:warn)
    end

    it 'parses the titles' do
      title_fields.each do |field_name|
        expect(document[field_name].first).to match(/Language and Mortality/)
      end
    end
  end
end
