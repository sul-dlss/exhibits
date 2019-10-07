# frozen_string_literal: true

require 'rails_helper'

describe MiradorHelper, type: :helper do
  let(:manifest) { 'https://example.edu/manifest.json' }
  let(:canvas) { 'https://example.edu/manifest1/canvas1' }
  let(:exhibit_slug) { 'default' }

  describe 'mirador settings propagation' do
    it 'includes the manifest url in the data array' do
      mirador_options = mirador_options(manifest, canvas, exhibit_slug)
      expect(mirador_options[:data].first[:manifestUri]).to be manifest
    end

    it 'includes the manifest url and canvas uri in the windowObject' do
      mirador_options = mirador_options(manifest, canvas, exhibit_slug)
      expect(mirador_options[:windowObjects].first[:loadedManifest]).to be manifest
      expect(mirador_options[:windowObjects].first[:canvasID]).to be canvas
    end

    context 'default exhibit' do
      it 'is a mirador config without sidepanel settings' do
        side_panel_options = mirador_options(manifest, canvas, exhibit_slug)[:sidePanelOptions]
        window_settings = mirador_options(manifest, canvas, exhibit_slug)[:windowSettings]
        expect(side_panel_options[:tocTabAvailable]).to be true
        expect(side_panel_options[:layersTabAvailable]).to be true
        expect(side_panel_options[:searchTabAvailable]).to be true
        expect(window_settings[:sidePanel]).to be true
        expect(window_settings[:sidePanelVisible]).to be false
      end
    end

    context 'exhibit has its own configuration' do
      let(:exhibit_slug) { 'test-flag-exhibit-slug' }

      it 'is a mirador config with special sidepanel settings' do
        side_panel_options = mirador_options(manifest, canvas, exhibit_slug)[:sidePanelOptions]
        window_settings = mirador_options(manifest, canvas, exhibit_slug)[:windowSettings]
        expect(side_panel_options[:tocTabAvailable]).to be true
        expect(side_panel_options[:layersTabAvailable]).to be false
        expect(side_panel_options[:searchTabAvailable]).to be true
        expect(window_settings[:sidePanel]).to be true
        expect(window_settings[:sidePanelVisible]).to be true
      end
    end
  end
end
