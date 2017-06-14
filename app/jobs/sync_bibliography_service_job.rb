##
# Background job to sync bibliography service
class SyncBibliographyServiceJob < ActiveJob::Base
  def perform(exhibit)
    SyncBibliographyService.new(exhibit).sync
  end
end
