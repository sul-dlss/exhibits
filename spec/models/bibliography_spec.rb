# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bibliography do
  subject(:bibliography) { described_class.new(bibtex) }

  context 'rendering bibliography as HTML' do
    context 'phdthesis' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/phdthesis.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'Wilson, E. A. 1968. “A Critic'\
          'al Text, with Commentary of MS Eng. Theol. f. 39 in the Bodleian Li'\
          'brary.” B.Litt., Oxford: University of Oxford.'
      end
    end

    context 'incollection' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/incollection.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'Whatley, E. G. 1986. “A ‘Symp'\
        'le Wrecche’ at Work: the Life and Miracles of St. Erkenwald in the Gi'\
        'lte Legende, BL Add. 35298.” In <i>Legenda Aurea. Sept Siècles De Dif'\
        'fusion. Actes Du Colloque International Sur La Legenda Aurea, Univers'\
        'ité Du Québec, Montréal, 11-12 Mai 1983</i>, edited by B. Dunn-Lardea'\
        'u, 333–43. Montréal/Paris.'
      end
    end

    context 'book' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/book.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'de Azevedo, R. 1962. <i>A Car'\
        'ta Ou Memória Do Cruzado Inglês R. Para Osberto De Bawdsey Sobre a Co'\
        'nquista De Lisboa Em 1147</i>. Coimbra: Faculdade de Letras da Univer'\
        'sidade de Coimbra.'
      end
    end

    context 'article' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/article.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'Wille, Clara. 2004. “Quelques'\
        ' Observations Sur Le Porc-Épic Et Le Hérisson Dans La Littérature Et '\
        'l’Iconographie Médiévale.” <i>Reinardus. Yearbook of the Internationa'\
        'l Reynard Society</i> 17: 181–201. doi:10.1075/rein.17.14wil.'
      end
    end
  end

  context 'sorting bibliography' do
    let(:bibtex) { `cat spec/fixtures/bibliography/*.bib` }
    it '#bibliography (unsorted)' do
      expect(bibliography.bibliography.collect(&:id)).to eq %w(
        http://zotero.org/groups/1051392/items/QTWBAWKX
        http://zotero.org/groups/1051392/items/TXXUJDG2
        http://zotero.org/groups/1051392/items/EI8BRRXB
        http://zotero.org/groups/1051392/items/JMIMQVT6
        http://zotero.org/groups/1051392/items/E9MZZKFV
        http://zotero.org/groups/1051392/items/6Q6TF4HD
        http://zotero.org/groups/1051392/items/E3MS2TQK
      )
    end
    it '#to_html (in sorted order)' do
      expect(bibliography.to_html).to eq File.read('spec/fixtures/bibliography/rendered.html').strip
    end
  end

  context 'initializer support for different forms' do
    context 'a BibTeX::Bibliography' do
      let(:bibtex) { BibTeX.open('spec/fixtures/bibliography/phdthesis.bib') }
      it '#bibliography' do
        expect(bibliography.bibliography).to be_a(BibTeX::Bibliography)
      end
    end
    context 'a Pathname' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/phdthesis.bib') }
      it '#bibliography' do
        expect(bibliography.bibliography).to be_a(BibTeX::Bibliography)
      end
    end
    context 'a String (data)' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/phdthesis.bib').read }
      it '#bibliography' do
        expect(bibliography.bibliography).to be_a(BibTeX::Bibliography)
      end
    end
    context 'an unsupported form' do
      let(:bibtex) { nil }
      it '#bibliography' do
        expect { bibliography.bibliography }.to raise_error(ArgumentError, /Unsupported type/)
      end
    end
  end
end
