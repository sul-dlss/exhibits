# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  # Collection titles are indexed as a compound druid + title; we need to
  # unmangle it for display.
  def collection_title(value, separator: '-|-')
    value.split(separator).last
  end

  def document_collection_title(value:, **)
    Array(value).map { |v| collection_title(v) }.to_sentence
  end

  def document_leaflet_map(document:, **)
    render_document_partial(document, 'show_leaflet_map_wrapper')
  end

  ##
  # @param [String] manifest
  def iiif_drag_n_drop(manifest, width: '40')
    link_url = format Settings.iiif_dnd_base_url, query: { manifest: manifest }.to_query
    link_to link_url, class: 'iiif-dnd float-right', data: { turbolinks: false } do
      image_tag 'iiif-drag-n-drop.svg', width: width, alt: 'IIIF Drag-n-drop'
    end
  end

  ### TODO: LOOK HERE ??
  ##
  # Renders a viewer for an object with understanding of the context. In the
  # context of spotlight/catalog render the configured viewer. In other contexts
  # (feature page) render the default viewer. Now passes through a "block" from
  # SirTrevor, used for rendering viewers in specific ways (canvas index).
  # @param [SolrDocument] document
  # @param [SirTrevorRails::Blocks::SolrDocumentsEmbedBlock] block
  def render_viewer_in_context(document, block = nil)
    # This is what is in the SirTrevor block
    #<SirTrevorRails::Blocks::SolrDocumentsEmbedBlock maxheight="", title="", text-align="left", text="<p><br></p>", format="html", item={"item_0"=>{"id"=>"xy658qf4887", "title"=>"Atlas Vidal. Lablache", "thumbnail_image_url"=>"https://stacks.stanford.edu/image/iiif/xy658qf4887%2Fxy658qf4887_00_0001/full/!400,400/0/default.jpg", "full_image_url"=>"https://stacks.stanford.edu/image/iiif/xy658qf4887%2Fxy658qf4887_00_0001/full/!400,400/0/default.jpg", "iiif_tilesource"=>"undefined", "iiif_manifest_url"=>"undefined", "iiif_canvas_id"=>"undefined", "iiif_image_id"=>"undefined", "weight"=>"0", "display"=>"true", "iiif_tilesource_base"=>"undefined"}, "item_1"=>{"id"=>"6370fd1a2c37a75e48afa52546a7ed42", "title"=>"Bodleian Library MS. Ind. Inst. Misc. 22", "thumbnail_image_url"=>"", "full_image_url"=>"", "iiif_tilesource"=>"https://iiif.bodleian.ox.ac.uk/iiif/image/cea63497-246b-4701-a140-8f0ad634d949/info.json", "iiif_manifest_url"=>"https://iiif.bodleian.ox.ac.uk/iiif/manifest/e32a277e-91e2-4a6d-8ba6-cc4bad230410.json", "iiif_canvas_id"=>"https://iiif.bodleian.ox.ac.uk/iiif/canvas/cea63497-246b-4701-a140-8f0ad634d949.json", "iiif_image_id"=>"https://iiif.bodleian.ox.ac.uk/iiif/annotation/cea63497-246b-4701-a140-8f0ad634d949.json", "weight"=>"2", "display"=>"true"}}>
    canvas = choose_canvas_id(block) if block

    if params[:controller] == 'spotlight/catalog'
      render partial: current_exhibit.required_viewer.to_partial_path,
             locals: { document: document, block: block, canvas: canvas }
    else
      #current_exhibit.required_viewer.default_viewer_path = oembed_default
      render partial: current_exhibit.required_viewer.default_viewer_path,
             locals: { document: document, block: block, canvas: canvas }
    end
  end

  ##
  #
  # @param [SolrDocument] document
  # @param [Integer] canvas_id
  def custom_render_oembed_tag_async(document, canvas_id, block)
    url = context_specific_oembed_url(document)
    
    # fake data
    # TODO: pull from DB
    file_path = Rails.root.join('mainstate.json')
    json_content = File.read(file_path)
    json_data = JSON.parse(json_content)


    content_tag :div, '', data: {
      embed_url: blacklight_oembed_engine.embed_url(
        url: url,
        canvas_id: canvas_id,
        # shows up in PURL/Oembed viewer only
        workspace_state: json_content,
        search: params[:search],
        maxheight: block&.maxheight.presence || '600',
        suggested_search: (current_search_session&.query_params || {})[:q]
      )
    }
  end

  # *** IMPORTANT for this feature.
  ##
  # This method sends the message of which IIIF canvas should be selected by the sul-embed viewer.
  # @param [SirTrevorRails::Blocks::SolrDocumentsEmbedBlock] block
  # @return [String] Selected canvas URI
  def choose_canvas_id(sir_trevor_block)
    sir_trevor_block&.items&.dig(0, 'iiif_canvas_id') if sir_trevor_block.respond_to? :items
  end

  def context_specific_oembed_url(document)
    if feature_flags.uat_embed? && document['druid'].present?
      format(Settings.purl.uat_url, druid: document['druid'])
    else
      document.first(blacklight_config.show.oembed_field)
    end
  end

  ##
  # Splits an array of strings on internal whitespace breaks
  def split_on_white_space(values)
    values.map { |v| v.gsub('&#10;', "\n").split("\n") }.flatten.compact
  end
end
