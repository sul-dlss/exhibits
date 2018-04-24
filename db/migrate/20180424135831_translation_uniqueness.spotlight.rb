# This migration comes from spotlight (originally 20180403130857)
class TranslationUniqueness < ActiveRecord::Migration[5.0]
  def change
    add_index(:translations, [:exhibit_id, :key, :locale], unique: true)
  end
end
