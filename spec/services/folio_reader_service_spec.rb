# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FolioReaderService do
  let(:folio_reader) { described_class.new(folio_instance_hrid: instance_hrid) }
  let(:folio_reader_marc_result) { folio_reader.to_marc }

  let(:marc_hash) do
    {
      'fields' => [
        { '001' => 'something_to_be_replaced' },
        { '003' => 'SIRSI' },
        { '005' => '19900820141050.0' },
        { '008' => '750409s1961||||enk           ||| | eng  ' },
        { '010' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => '   62039356\\\\72b2' }] } },
        { '040' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'd' => 'OrLoB' }] } },
        { '050' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => 'M231.B66 Bb maj. 1961' }] } },
        { '100' =>
          { 'ind1' => '1', 'ind2' => ' ', 'subfields' => [{ 'a' => 'Boccherini, Luigi,' }, { 'd' => '1743-1805.' }] } },
        { '240' =>
          { 'ind1' => '1',
            'ind2' => '0',
            'subfields' => [{ 'a' => 'Sonatas,' }, { 'm' => 'cello, continuo,' }, { 'r' => 'B♭ major' }] } },
        { '245' =>
          { 'ind1' => ' ',
            'ind2' => '0',
            'subfields' =>
            [{ 'a' => 'Sonata no. 7, in B flat, for violoncello and piano.' },
             { 'c' =>
               'Edited with realization of the basso continuo by Fritz Spiegl and Walter Bergamnn. Violoncello part edited by Joan Dickson.' }] } }, # rubocop:disable Layout/LineLength
        { '260' =>
          { 'ind1' => ' ',
            'ind2' => ' ',
            'subfields' =>
            [{ 'a' => 'London, Schott; New York, Associated Music Publishers' }, { 'c' => '[c1961]' }] } },
        { '300' => { 'ind1' => ' ', 'ind2' => ' ',
                     'subfields' => [{ 'a' => 'score (20 p.) & part.' }, { 'c' => '29cm.' }] } },
        { '490' => { 'ind1' => '1', 'ind2' => ' ', 'subfields' => [{ 'a' => 'Edition [Schott]  10731' }] } },
        { '500' =>
          { 'ind1' => ' ',
            'ind2' => ' ',
            'subfields' =>
            [{ 'a' =>
              "Edited from a recently discovered ms. Closely parallels Gruetzmacher's free arrangement of the Violoncello concerto, G. 482." }] } }, # rubocop:disable Layout/LineLength
        { '596' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => '31' }] } },
        { '650' => { 'ind1' => ' ', 'ind2' => '0', 'subfields' => [{ 'a' => 'Sonatas (Cello and harpsichord)' }] } },
        { '700' =>
          { 'ind1' => '1',
            'ind2' => '2',
            'subfields' =>
            [{ 'a' => 'Boccherini, Luigi,' },
             { 'd' => '1743-1805.' },
             { 't' => 'Concertos,' },
             { 'm' => 'cello, orchestra,' },
             { 'n' => 'G. 482,' },
             { 'r' => 'B♭ major' },
             { 'o' => 'arranged.' }] } },
        { '830' => { 'ind1' => ' ', 'ind2' => '0', 'subfields' => [{ 'a' => 'Edition Schott' }, { 'v' => '10731' }] } },
        { '998' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => 'SCORE' }] } },
        { '035' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => '(OCoLC-M)17708345' }] } },
        { '035' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => '(OCoLC-I)268876650' }] } },
        { '918' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => '666' }] } },
        { '035' => { 'ind1' => ' ', 'ind2' => ' ', 'subfields' => [{ 'a' => 'AAA0675' }] } },
        { '999' =>
          { 'ind1' => 'f',
            'ind2' => 'f',
            'subfields' =>
            [{ 'i' => '696ef04d-1902-5a70-aebf-98d287bce1a1' },
             { 's' => '992460aa-bfe6-50ff-93f6-65c6aa786a43' }] } }
      ],
      'leader' => '01185ccm a2200301   4500'
    }
  end

  context 'when instance_hrid passed in' do
    let(:instance_hrid) { 'a666' }

    describe '#to_marc' do
      context 'when Folio API successfully returns a single result' do
        before do
          allow(FolioClient).to receive(:fetch_marc_hash).with(instance_hrid:).and_return(marc_hash)
        end

        it 'builds a MARC::Record object from the hash returned by the API client' do
          expect(folio_reader_marc_result).to be_a(MARC::Record)
          # the 001 and 003 fields have been changed
          expect(folio_reader_marc_result['001'].value).to eq instance_hrid # used to be a bogus value
          expect(folio_reader_marc_result['003'].value).to eq 'FOLIO' # used to be SIRSI

          # these stay the same
          expect(folio_reader_marc_result['100']['a']).to eq('Boccherini, Luigi,')
          expect(folio_reader_marc_result['240']['m']).to eq('cello, continuo,')
          expect(folio_reader_marc_result['245']['a']).to eq('Sonata no. 7, in B flat, for violoncello and piano.')
        end
      end

      context 'when folio_client encounters an unexpected response and raises an error' do
        before do
          allow(FolioClient).to receive(:fetch_marc_hash)
            .with(instance_hrid:).and_raise(FolioClient::ResourceNotFound, "No records found for #{instance_hrid}")
        end

        it 'lets the exception bubble up to the caller' do
          expect do
            folio_reader_marc_result
          end.to raise_error(FolioClient::ResourceNotFound, "No records found for #{instance_hrid}")
        end
      end
    end
  end
end
