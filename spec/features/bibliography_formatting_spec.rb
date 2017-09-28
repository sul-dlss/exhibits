require 'rails_helper'

RSpec.feature 'Bibliography formatting' do
  subject(:bibliography) { Exhibits::Bibliography.new(bibtex) }

  context 'rendering bibliography as HTML' do
    context 'phdthesis' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/phdthesis.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'Wilson, E. A. 1968. “A Critical Text, with Commentary of MS Eng. Theol. f. 39 in the Bodleian Library.” B.Litt., Oxford: University of Oxford.'
      end
    end

    context 'incollection' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/incollection.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'Whatley, E. G. 1986. “A ‘Symple Wrecche’ at Work: the Life and Miracles of St. Erkenwald in the Gilte Legende, BL Add. 35298.” In <i>Legenda Aurea. Sept Siècles De Diffusion. Actes Du Colloque International Sur La Legenda Aurea, Université Du Québec, Montréal, 11-12 Mai 1983</i>, edited by B. Dunn-Lardeau, 333–43. Montréal/Paris.'
      end
    end

    context 'book' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/book.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'de Azevedo, R. 1962. <i>A Carta Ou Memória Do Cruzado Inglês R. Para Osberto De Bawdsey Sobre a Conquista De Lisboa Em 1147</i>. Coimbra: Faculdade de Letras da Universidade de Coimbra.'
      end
    end

    context 'article' do
      let(:bibtex) { Pathname('spec/fixtures/bibliography/article.bib') }

      it '#to_html' do
        expect(bibliography.to_html).to include 'Wille, Clara. 2004. “Quelques Observations Sur Le Porc-Épic Et Le Hérisson Dans La Littérature Et l’Iconographie Médiévale.” <i>Reinardus. Yearbook of the International Reynard Society</i> 17: 181–201. doi:10.1075/rein.17.14wil.'
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
