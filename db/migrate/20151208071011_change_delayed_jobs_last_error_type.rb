class ChangeDelayedJobsLastErrorType < ActiveRecord::Migration[5.0]
  def up
    change_column :delayed_jobs, :last_error, :text, limit: 4294967295
  end
end
