##
# delayed_job monitoring dashboard
class DelayedJobsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: 'Delayed::Job'

  def index
  end

  def update
    Delayed::Worker.new.run(@delayed_job)

    respond_to do |format|
      format.html { redirect_to delayed_jobs_url }
      format.json { head :no_content }
    end
  end

  def destroy
    @delayed_job.destroy

    respond_to do |format|
      format.html { redirect_to delayed_jobs_url }
      format.json { head :no_content }
    end
  end
end
