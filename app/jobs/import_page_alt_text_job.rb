# frozen_string_literal: true

# A job to import alt text for home/about/feature pages from the AI alt text experiments.
class ImportPageAltTextJob < ApplicationJob
  def perform(csv_path:, dry_run: false)
    update = !dry_run

    CSV.foreach(csv_path, headers: true) do |csv_row|
      row = AltTextSpreadsheetRow.new(csv_row)

      unless row.valid?
        Rails.logger.error "Skipping invalid row: #{row.inspect}"
        next
      end

      if row.decorative?
        set_page_image_as_decorative!(row:, update:)
      else
        update_page_image_alt_text!(row:, update:)
      end
    end
  end

  private

  def set_page_image_as_decorative!(row:, update: true)
    item = find_item_to_update(row:)
    return unless item

    if update
      item['alt_text_backup'] = item['alt_text']
      item['alt_text'] = ''
      item['decorative'] = 'on'
      row.page.update!(content: row.page.content)
    end
    Rails.logger.info "Set image '#{row.image_url}' as decorative on page '#{row.page.title}'"
  end

  def update_page_image_alt_text!(row:, update: true)
    item = find_item_to_update(row:)
    return unless item

    if update
      item.delete('decorative')
      item['alt_text'] = row.alt_text
      row.page.update!(content: row.page.content)
    end
    Rails.logger.info "Updated alt text for image #{row.image_url} on page #{row.page.title}"
  end

  def find_item_to_update(row:)
    items = if row.uploaded_image?
              uploaded_items_with_image(page: row.page, uploaded_image_url: row.uploaded_image_url)
            elsif row.druid
              solrdocument_items_with_image(page: row.page, druid: row.druid)
            end

    unless items&.count&.positive?
      Rails.logger.error "Failed to find block/item that uses image from row: #{row.inspect}"
      return
    end

    return items.first if items.count == 1

    Rails.logger.error "Ambiguous match for '#{row.image_url}', row skipped: #{row.inspect}"
  end

  def solrdocument_items_with_image(page:, druid:)
    return nil if page.content.blank?

    items = page.content.flat_map do |block|
      next [] unless block.supports_alt_text? && block.items.present?

      # It might be tempting to check if the thumbnail urls match, but thumbnail_image_url isn't always set...
      block.items&.select { |item| item['id'] == druid }
    end

    items.compact
  end

  def uploaded_items_with_image(page:, uploaded_image_url:)
    return nil if page.content.blank?

    items = page.content.flat_map do |block|
      next [] unless block.supports_alt_text? && block.item.present?

      block.item.select { |_id, item| item['url'] == uploaded_image_url }.map { |_id, item| item }
    end

    items.compact
  end

  # Model the existing Alt Text spreadsheet. If we keep this workflow it could be a real model but this is
  # supposedly a short-lived process, so let's keep it all in one place.
  class AltTextSpreadsheetRow
    module Headers
      EXHIBIT = 'Exhibit'
      PAGE_URL = 'Page URL'
      IMAGE_URL = 'Image URL'
      DECORATIVE = 'Image is DECORATIVE, no description required (mark with an "X" if so)'
      AI_ALT_TEXT = 'AI Generated Description (gemini-2.0-flash)'
      HUMAN_ALT_TEXT = 'New OR edited description (when needed)'
      NOT_USEFUL = 'AI description NOT useful and new, accurate alt text must be created (mark with an "X" if so)'
      USEFUL_AS_IS = 'AI description useful AS IS (mark with an "X" if so)'
      PARTIALLY_USEFUL = 'AI description partially useful with EDITS NEEDED (mark with an "X" if so)'
    end
    attr_reader :row

    def initialize(row)
      @row = row
    end

    def exhibit
      @exhibit ||= Spotlight::Exhibit.find_by(title: exhibit_title)
    end

    def page
      @page ||= case page_type
                when :home
                  exhibit.home_page
                when :about
                  exhibit.about_pages.find_by(slug: page_slug)
                else
                  exhibit.feature_pages.find_by(slug: page_slug)
                end
    end

    def decorative?
      row[Headers::DECORATIVE].to_s.strip.downcase == 'x'
    end

    def druid
      image_url[%r{image/iiif/([^%]+?)/}, 1] if image_url.present?
    end

    def uploaded_image_url
      image_url[%r{(/uploads/spotlight/attachment/.*)}, 1] if image_url.present?
    end

    def uploaded_image?
      uploaded_image_url.present?
    end

    def alt_text
      if useful_as_is?
        ai_alt_text
      elsif not_useful? || partially_useful?
        human_alt_text.presence
      end
    end

    def valid?
      return false unless exhibit.present? && page.present?

      single_selection? && (druid.present? || uploaded_image?) && (alt_text.present? || decorative?)
    end

    def image_url
      url = row[Headers::IMAGE_URL]&.strip
      URI.decode_uri_component(url) if url.present?
    end

    private

    def ai_alt_text
      row[Headers::AI_ALT_TEXT]&.strip
    end

    def human_alt_text
      row[Headers::HUMAN_ALT_TEXT]&.strip
    end

    def not_useful?
      row[Headers::NOT_USEFUL].to_s.strip.downcase == 'x'
    end

    def useful_as_is?
      row[Headers::USEFUL_AS_IS].to_s.strip.downcase == 'x'
    end

    def partially_useful?
      row[Headers::PARTIALLY_USEFUL]
        .to_s.strip.downcase == 'x'
    end

    def single_selection?
      [not_useful?, useful_as_is?, partially_useful?, decorative?].count(true) == 1
    end

    def exhibit_path
      Spotlight::Engine.routes.url_helpers.exhibit_path(exhibit)
    end

    def exhibit_title
      row[Headers::EXHIBIT]
    end

    def page_slug
      page_path.split('/').last
    end

    def page_type
      if page_path == exhibit_path
        :home
      elsif page_path.include? "#{exhibit_path}/about/"
        :about
      else
        :feature
      end
    end

    def page_path
      URI(page_url).path if page_url.present?
    end

    def page_url
      row[Headers::PAGE_URL]
    end
  end
end
