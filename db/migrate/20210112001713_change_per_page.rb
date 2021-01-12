class ChangePerPage < ActiveRecord::Migration[5.2]
  def change
    Spotlight::Exhibit.find_each do |exhibit|
      config = exhibit.blacklight_configuration
      case config.default_per_page
      when 10
        config.default_per_page = 12
      when 20
        config.default_per_page = 24
      when 50
        config.default_per_page = 48
      when 100
        config.default_per_page = 96
      else
        config.default_per_page = 12
      end
      config.save
    end
  end
end
