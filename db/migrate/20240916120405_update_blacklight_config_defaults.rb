class UpdateBlacklightConfigDefaults < ActiveRecord::Migration[7.2]
  def up
    Spotlight::BlacklightConfiguration.reset_column_information

    Spotlight::BlacklightConfiguration.find_each do |config|
      config.update(
        facet_fields: config.facet_fields.reverse_merge({
          'name_ssim' => { 'show' => false },
          'name_roles_ssim' => { 'show' => false }
        })
      ) unless config.facet_fields.blank?

      config.update(
        index_fields: config.index_fields.reverse_merge({
          'name_roles_ssim' => { 'enabled' => false, 'show' => false }
        })
      ) unless config.index_fields.blank?
    end
  end
end
