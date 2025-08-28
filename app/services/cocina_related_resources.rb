# frozen_string_literal: true

# Class to handle generating labels and values for Cocina
# related resources
# 
# Returns a structure like this. Maybe these should be objects, but for now...
# { 'Contains' => [{ 'Title' => ['Ranulf Higden OSB, Polychronicon (epitome and continuation to 1429). 1r-29v'] },
#                  { 'Author' => ['Ranulf Higden OSB'] },
#                  { 'Note' => ['Assmann, A.-S. Homilien etc. p. 117'] }],
#   'Downloadable James Catalog Record' => [{ 'Title' => ['https://stacks.stanford.edu/file/vz744tc9861/MS_367.pdf'] }]
# }
class CocinaRelatedResources
  def initialize(related_resources:)
    @related_resources = related_resources
  end

  def related_resources_hash
    @related_resources_hash ||= related_resources.each_with_object(Hash.new { |h, k| h[k] = [] }) do |resource, hash|
      hash[resource_label(resource)] << RelatedResource.new(resource).resource_hash
    end
  end

  # Class that assembles a related resource hash
  class RelatedResource
    def initialize(resource)
      @resource = resource
    end

    def resource_hash
      {
        'Title' => [@resource.title],
        'Author' => [@resource.author],
        'Note' => [@resource.note],
        'M.R. James Date' => [@resource.mr_james_date]
      }
    end
  end
end
