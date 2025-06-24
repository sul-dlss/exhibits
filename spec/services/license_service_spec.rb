# frozen_string_literal: true

require 'rails_helper'

describe LicenseService do
  subject(:license_service) { described_class }

  let(:license_url) { 'https://www.apache.org/licenses/LICENSE-2.0' }
  let(:license_description) { 'This work is licensed under an Apache License 2.0.' }

  describe '.licenses' do
    it 'returns a hash of license URLs and their descriptions' do
      expect(license_service.licenses).to be_a(Hash)
      expect(license_service.licenses.keys).to include(license_url.to_sym)
    end
  end

  describe '.call' do
    it 'returns the human-readable description of the license' do
      expect(license_service.call(url: license_url)).to eq(license_description)
    end

    it 'raises LicenseServiceError for an invalid license URL' do
      expect { license_service.call(url: 'invalid_license') }.to raise_error(LicenseService::LicenseServiceError)
    end
  end

  describe '#initialize' do
    it 'initializes with a valid license URL' do
      service = license_service.new(url: license_url)
      expect(service.uri).to eq(license_url)
      expect(service.description).to eq(license_description)
    end

    it 'raises LicenseServiceError for an invalid license URL' do
      expect { license_service.new(url: 'invalid_license') }.to raise_error(LicenseService::LicenseServiceError)
    end
  end
end
