require 'rails_helper'

describe ZoteroApi::Client do
  subject { described_class.new 3_802_090 } # TODO: replace with fixtures, currently drh's public library
  context 'user' do
    context 'properties' do
      it '#endpoint' do
        expect(subject.endpoint).to eq "https://api.zotero.org/users/#{subject.zotero_id}"
      end
    end
    context 'many bibliography items' do
      it 'retrieves bibliography' do
        expect(subject.bibliography).to be_a(ZoteroApi::Bibliography)
        expect(subject.bibliography.first['key']).to eq 'J8ZWJ73E'
        expect(subject.bibliography.length).to eq 7
      end
      it 'sorts bibliography' do
        sorted = subject.bibliography.sort_by_author_date
        expect(sorted).to be_a(ZoteroApi::Bibliography)
        expect(sorted.first['key']).to eq 'ABCD2345'
        expect(sorted.length).to eq 7
      end
      it 'renders as HTML' do
        expect(subject.bibliography.render).to eq(
          File.read(Rails.root.join('spec', 'fixtures', 'zotero_user_3802090_rendered.html'))
        )
      end
      it 'builds inverted index' do
        expect(subject.inverted_index.keys.sort).to eq(%w(aa111bb2222 cc333dd4444 ee555ff6666))
        expect(subject.inverted_index['ee555ff6666']).to be_a(ZoteroApi::Bibliography)
        expect(subject.inverted_index['ee555ff6666'].collect { |i| i['key'] }).to include(
          'J8ZWJ73E', 'VG8GVGNQ', '8HQ6SRVX', 'ZNWKPQHK', 'DHNES6FB'
        )
      end
    end
    context 'one item' do
      let(:item) { subject.bibliography.find('J8ZWJ73E') }
      it '#tags' do
        expect(item.tags).to include('My Favorite Book (ee555ff6666)')
      end
      it '#druids' do
        expect(item.druids).to include('ee555ff6666')
      end
      it '#to_html' do
        expect(item.to_html).to eq(
          "<div class=\"csl-bib-body\" style=\"line-height: 1.35; padding-left: 2em; text-indent:-2em;\">\n" \
          "  <div class=\"csl-entry\">Doe, Jane, ed. <i>Yet Another Book</i>, 2001.</div>\n" \
          '</div>'
        )
      end
    end
  end
  context 'group' do # other than an endpoint, `group` is identical to `user` behavior
    subject { described_class.new 1_051_392, :group } # parker-library's group ID
    context 'properties' do
      it '#endpoint' do
        expect(subject.endpoint).to eq "https://api.zotero.org/groups/#{subject.zotero_id}"
      end
    end
    # context 'many bibliography' do
    #   it 'retrieves bibliography' do # TODO: this takes a looooong time (>10 mins)
    #     expect(subject.bibliography.length).to eq 7360
    #   end
    # end
  end
end
