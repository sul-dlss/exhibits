class ChangeDelayedJobsLastErrorType < ActiveRecord::Migration
  def up
    change_column :delayed_jobs, :last_error, :text, limit: 4294967295
  end
end
