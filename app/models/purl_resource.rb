class PurlResource
  include ActiveModel::Model
  extend ActiveModel::Translation
  
  attr_accessor :data, :exhibit

  def self.purls exhibit
    Spotlight::Resources::Purl.where(exhibit: exhibit).pluck(:url).map { |x| x.match(/^https?:\/\/purl.stanford.edu\/([^\/\.]+)/)[1] }.uniq
  end

  def exhibit_id
    exhibit.id
  end

  def save
    data.split("\n").map(&:strip).reject(&:blank?).each do |line|
      if line =~ /^\w{2}\d{3}\w{2}\d{4}$/
        r = Spotlight::Resources::Purl.new exhibit: exhibit, url: "http://purl.stanford.edu/#{line}"
        r.save!
      end
    end
  end

end