require 'nokogiri'
class SearchWorksItem
  def initialize id
    @id = id
  end
  def exists?
    response.code == "200"
  end
  def document
    @document ||= Nokogiri::XML(response.body)
  end
  def collection
    @collection ||= document.xpath("//collection").map do |collection|
      {id: collection.xpath("./id").text, title: collection.xpath("./title").text}
    end.first
  end
  private
  def response
    url = URI.parse(searchworks_url)
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url.request_uri)
    @response ||= http.request(request)
  end
  def searchworks_url
    "#{Settings.searchworks.api.prefix}#{@id}#{Settings.searchworks.api.suffix}"
  end
end
