# frozen_string_literal: true

require 'rails_helper'

describe CatalogHelper, type: :helper do
  describe '#has_thumbnail?' do
    context 'for references' do
      let(:document) { SolrDocument.new(format_main_ssim: ['Reference']) }

      it 'is true' do
        expect(has_thumbnail?(document)).to be true
      end
    end

    context 'for canvases' do
      let(:document) { SolrDocument.new(format_main_ssim: ['Page details']) }

      it { expect(has_thumbnail?(document)).to be true }
    end
  end

  describe '#render_thumbnail_tag' do
    before do
      expect(helper).to receive_messages(
        blacklight_config: CatalogController.blacklight_config,
        current_search_session: {},
        document_index_view_type: :list,
        search_state: instance_double('SearchState', url_for_document: '/'),
        search_session: {}
      )
    end
    context 'for references' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Reference']) }

      it 'renders a default thumbnail' do
        link = Capybara.string(helper.render_thumbnail_tag(document))
        expect(link).to have_css('a[data-context-href]')
        expect(link.find('img')['src']).to include 'default-square-thumbnail-book'
      end
    end

    context 'for canveses' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Page details']) }

      it 'renders a default thumbnail' do
        link = Capybara.string(helper.render_thumbnail_tag(document))
        expect(link).to have_css('a[data-context-href]')
        expect(link.find('img')['src']).to include 'default-square-thumbnail-annotation'
      end
    end
  end

  describe '#notes_wrap' do
    let(:output) { '<ul class="general-notes"><li>a</li><li><p>b</p><p>c</p></li><li>d</li></ul>' }

    it 'permits embedded HTML and handles multivalued notes as an unordered list' do
      expect(helper.notes_wrap(value: %w(a <p>b</p><p>c</p> d))).to eq output
    end
    context 'single note' do
      it 'returns the note' do
        expect(helper.notes_wrap(value: %w(<p>stuff</p>))).to eq '<p>stuff</p>'
      end
    end
  end

  describe '#table_of_contents_separator' do
    context 'single value' do
      let(:input) { { document: SolrDocument.new(id: 'cf386wt1778'), value: ['Homiliae'] } }

      it 'presents content inline' do
        expect(helper.table_of_contents_separator(input)).to eq 'Homiliae'
        expect(helper.table_of_contents_separator(input)).not_to match(/data-toggle='collapse'/)
      end
    end

    context 'multi-valued' do
      let(:input) { { document: SolrDocument.new(id: 'cf386wt1778'), value: ['Homiliae--euangelia'] } }

      it 'separates MODS table of contents' do
        expect(helper.table_of_contents_separator(input)).to match(%r{<li>Homiliae</li><li>euangelia</li>})
      end

      it 'collapses content' do
        expect(helper.table_of_contents_separator(input)).to match(/data-toggle='collapse'/)
      end
    end
  end

  describe '#manuscript_link' do
    let(:druid) { 'bg021sq9590' }
    let(:input) { { value: [druid], document: document } }
    let(:show_page) { "/test-flag-exhibit-slug/catalog/#{druid}" }

    before do
      helper.extend(Module.new do
        def current_exhibit
          FactoryBot.create(:exhibit, slug: 'test-flag-exhibit-slug')
        end
      end)
    end

    context 'page details' do
      let(:title) { 'Baldwin of Ford OCist, De sacramento altaris' }
      let(:document) do
        SolrDocument.new(
          title_full_display: "p. 3:#{title}",
          manuscript_number_tesim: ['MS 198'],
          format_main_ssim: ['Page details']
        )
      end

      it 'removes page prefix if present' do
        expect(helper.manuscript_link(input)).to have_link(text: title, href: show_page)
      end
    end

    context 'bibilography resource' do
      let(:document) do
        SolrDocument.new(
          title_full_display: 'A Zotero reference',
          format_main_ssim: ['Bibliography']
        )
      end

      it 'displays druid for Bibliography resources' do
        expect(helper.manuscript_link(input)).to have_link(text: druid, href: show_page)
      end
    end
  end

  describe '#render_fulltext_highlight' do
    context 'when there is no value' do
      it 'is nil' do
        expect(helper.render_fulltext_highlight(value: [])).to be_nil
      end
    end

    context 'when there are values' do
      it 'wraps each value in a paragraph tag' do
        ps = helper.render_fulltext_highlight(value: %w(Value1 Value2))
        expect(ps).to eq '<p>Value1</p><p>Value2</p>'
      end
    end
  end
end
