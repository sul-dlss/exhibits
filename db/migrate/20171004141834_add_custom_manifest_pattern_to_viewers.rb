class AddCustomManifestPatternToViewers < ActiveRecord::Migration[5.0]
  def change
    add_column :viewers, :custom_manifest_pattern, :text
  end
end
