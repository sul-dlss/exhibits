##
# Shim class for taking a list of druids and turning them into
# exhibit resources.
class PurlResource
  include ActiveModel::Model
  extend ActiveModel::Translation

  attr_accessor :data, :exhibit

  def self.druids(exhibit)
    resources(exhibit).pluck(:url).map do |x|
      x.match(%r{^https?://purl.stanford.edu/([^/\.]+)})[1]
    end.uniq
  end

  def self.resources(exhibit)
    Spotlight::Resources::Purl.where(exhibit: exhibit)
  end

  delegate :id, to: :exhibit, prefix: true

  def save
    data.split("\n").map(&:strip).reject(&:blank?).each do |line|
      next unless line =~ /^\w{2}\d{3}\w{2}\d{4}$/
      exhibit.resources.find_or_create_by(type: 'Spotlight::Resources::Purl',
                                          exhibit: exhibit,
                                          url: "https://purl.stanford.edu/#{line}")
    end
  end
end
