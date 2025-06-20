# frozen_string_literal: true

##
# FullTextParser takes in a purl object resources and knows
# how to find full-text resources (either plain-text or ALTO xml)
# and can return an array of OCR strings (one element in the array for every OCR file).
class FullTextParser
  attr_reader :druid, :purl_object
  delegate :public_cocina, to: :purl_object

  TRANSCRIPTION_FILE_USE = 'transcription'
  TRANSCRIPTION_FILE_MIMETYPES = %w(text/plain text/html application/xml application/alto+xml).freeze
  TRANSCRIPTION_RESOURCE_TYPES = %w(https://cocina.sul.stanford.edu/models/resources/page
                                    https://cocina.sul.stanford.edu/models/resources/image).freeze

  XML_OCR_TYPES = %w(application/xml application/alto+xml).freeze
  HTML_OCR_TYPES = %w(text/html).freeze

  # @param purl_object [Purl] the Purl object containing the resources to parse
  def initialize(purl_object)
    @purl_object = purl_object
    @druid = purl_object.bare_druid
  end

  # @return [Array<Hash>] an array of hashes representing the OCR files
  def ocr_files
    @ocr_files ||= transcription_files.concat(text_transcription_files)
  end

  # TODO: Support .rtf (and .xml?) files, scrubbing/converting as necessary to get plain text
  # @return [Array<String>] an array of strings representing the full text content of the OCR files
  def to_text
    ocr_files.map do |resource|
      url = full_text_url(resource.fetch('filename', ''))
      content = full_text_content(url)
      if XML_OCR_TYPES.include?(resource.fetch('hasMimeType', ''))
        alto_xml_string_content(content)
      elsif HTML_OCR_TYPES.include?(resource.fetch('hasMimeType', ''))
        hocr_string_content(content)
      else # plain text
        content.scrub.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').gsub(/\s+/, ' ')
      end
    end
  end

  private

  def full_text_content(url)
    Faraday.get(url).body
  rescue Faraday::ConnectionFailed
    Rails.logger.error("Error indexing full text - couldn't load file #{url}")
    ''
  end

  def full_text_url(file_name)
    "#{::Settings.stacks.file_url}/#{druid}/#{ERB::Util.url_encode(file_name)}"
  end

  def alto_xml_string_content(content)
    return [] if content.blank?

    alto = Nokogiri::XML.parse(content)
    alto_ns = alto.namespaces.values.first { |ns| ns =~ %r{standards/alto/ns} }
    namespace = { alto: alto_ns || 'http://www.loc.gov/standards/alto/ns-v3#' }
    alto.xpath('//alto:String/@CONTENT', namespace).map(&:text).join(' ')
  end

  def hocr_string_content(content)
    return [] if content.blank?

    hocr = Nokogiri::HTML.parse(content)
    hocr.css('.ocr_page').map(&:text).join(' ')
  end

  # Supports feigenbaum style transcription files
  # where the filename is the druid with a .txt extension.
  def text_transcription_files
    public_cocina_contains.flat_map do |resource|
      resource_contains(resource).select do |file|
        file.fetch('filename', '') == "#{druid}.txt"
      end
    end
  end

  def transcription_files
    transcription_resources.flat_map do |resource|
      resource_contains(resource).select do |file|
        file.fetch('use', '') == TRANSCRIPTION_FILE_USE &&
          file.fetch('hasMimeType').in?(TRANSCRIPTION_FILE_MIMETYPES)
      end
    end
  end

  def transcription_resources
    public_cocina_contains.select do |resource|
      resource.fetch('type', '').in?(TRANSCRIPTION_RESOURCE_TYPES)
    end
  end

  def public_cocina_contains
    resource_contains(public_cocina)
  end

  def resource_contains(resource)
    Array(resource.dig('structural', 'contains'))
  end
end
