# frozen_string_literal: true

##
# FullTextParser takes in a purl object resources and knows
# how to find full-text resources (either plain-text or ALTO xml)
# and can return an array of OCR strings (one element in the array for every OCR file).
class FullTextParser
  attr_reader :druid, :purl_object
  delegate :public_xml, to: :purl_object

  def initialize(purl_object)
    @purl_object = purl_object
    @druid = purl_object.bare_druid
  end

  def ocr_files
    @ocr_files ||= xpath.flat_map { |xp| public_xml.xpath(xp) }
  end

  # TODO: Support .rtf (and .xml?) files, scrubbing/converting as necessary to get plain text
  def to_text
    ocr_files.map do |resource|
      url = full_text_url(resource['id'])
      content = full_text_content(url)
      if xml_ocr_types.include?(resource['mimetype'])
        alto_xml_string_content(content)
      elsif html_ocr_types.include?(resource['mimetype'])
        hocr_string_content(content)
      else # plain text
        content.scrub.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?').gsub(/\s+/, ' ')
      end
    end
  end

  private

  def xml_ocr_types
    ['application/xml', 'application/alto+xml']
  end

  def html_ocr_types
    ['text/html']
  end

  def full_text_content(url)
    Faraday.get(url).body
  rescue Faraday::ConnectionFailed
    logger.error("Error indexing full text - couldn't load file #{url}")
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

  # full text in druid.txt named for druid (feigenbaum) and ALTO OCR xml in page resources
  # rubocop:disable Layout/LineLength
  def xpath
    [
      "//contentMetadata/resource/file[@id=\"#{druid}.txt\"]",
      "//contentMetadata/resource[@type='page']/file[@role='transcription'][@mimetype='text/plain' or @mimetype='text/html' or @mimetype='application/xml' or @mimetype='application/alto+xml']",
      "//contentMetadata/resource[@type='image']/file[@role='transcription'][@mimetype='text/plain' or @mimetype='text/html' or @mimetype='application/xml' or @mimetype='application/alto+xml']"
    ]
  end
  # rubocop:enable Layout/LineLength

  def logger
    Rails.logger
  end
end
