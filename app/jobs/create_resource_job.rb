# frozen_string_literal: true

# Persist JSON resources and index them
class CreateResourceJob < ActiveJob::Base
  queue_as :default

  def perform(id, exhibit, data)
    # TODO: Implement with https://github.com/projectblacklight/spotlight/wiki/Resource-Scenarios#on-demand-resource-indexing
  end
end
