# frozen_string_literal: true

##
# A job to add or delete exhibit index documents
class IndexExhibitMetadataJob < ApplicationJob
  def perform(exhibit:, action:)
    case action
    when 'add'
      ExhibitIndexer.new(exhibit).add
    when 'delete'
      ExhibitIndexer.new(exhibit).delete
    end
  end
end
