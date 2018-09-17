# frozen_string_literal: true

require 'digest'
require 'faraday'
require_relative 'extraction'

module Macros
  # IIIF canvas extraction
  module Canvas
    def extract_parent_manifest_iiif_id
      lambda do |_record, accumulator, context|
        return if context.output_hash['related_document_id_ssim'].blank?

        accumulator << format(Settings.purl.iiif_manifest_url,
                              druid: context.output_hash['related_document_id_ssim'].first.to_s)
      end
    end

    def extract_canvas_id
      lambda do |record, accumulator, _context|
        accumulator << "canvas-#{Digest::MD5.hexdigest(record['@id'].to_s)}"
      end
    end

    def extract_canvas_iiif_id
      lambda do |record, accumulator, _context|
        accumulator << record['@id'].to_s
      end
    end

    ##
    # Note: This method assumes an "enhanced" canvas with additional properties
    # added beyond the IIIF Canvas model.
    def extract_canvas_label
      lambda do |record, accumulator, _context|
        labels = [record['label'].to_s, record['manifest_label'].to_s].reject(&:empty?)
        accumulator << labels.join(': ')
      end
    end

    ##
    # Note: This method assumes an "enhanced" canvas with additional properties
    # added beyond the IIIF Canvas model.
    def extract_canvas_label_sort
      lambda do |record, accumulator, _context|
        labels = [record['manifest_label'].to_s, record['label'].to_s].reject(&:empty?)
        accumulator << labels.join(': ')
      end
    end

    def extract_canvas_parent_manuscript_number
      lambda do |record, accumulator, _context|
        return if record['parent_manuscript_number'].blank?

        accumulator.push(*record['parent_manuscript_number'].map(&:to_s))
      end
    end

    ##
    # Note: This method assumes an "enhanced" canvas with additional properties
    # added beyond the IIIF Canvas model.
    def extract_canvas_range_labels
      lambda do |record, accumulator, _context|
        return if record['range_labels'].blank?

        accumulator.push(*record['range_labels'].map(&:to_s))
      end
    end

    def extract_canvas_annotation_list_urls
      lambda do |record, accumulator, _context|
        return if record['otherContent'].blank?

        record['otherContent'].each do |link|
          next unless link['@type'] == 'sc:AnnotationList'

          accumulator << link['@id'].to_s
        end
      end
    end

    def extract_canvas_annotations
      lambda do |record, accumulator, _context|
        return if record['otherContent'].blank?

        record['otherContent'].each do |link|
          next unless link['@type'] == 'sc:AnnotationList'

          extract_annotations_from_list(accumulator, link['@id'].to_s)
        end
      end
    end

    # Druids are kept as part of the canvas-id
    def extract_canvas_related_document_ids
      lambda do |record, accumulator, _context|
        match = record['@id'][Exhibits::Application.config.druid_regex]
        return if match.blank?

        accumulator << match
      end
    end

    private

    def extract_annotations_from_list(accumulator, url)
      annotation_list = JSON.parse(Faraday.get(url).body)
      return unless annotation_list['@type'] == 'sc:AnnotationList' && annotation_list['resources']

      annotation_list['resources'].each do |resource|
        next unless resource['@type'] == 'oa:Annotation'
        next if resource['resource']['chars'].blank?

        accumulator << resource['resource']['chars'].to_s
      end
    end
  end
end
