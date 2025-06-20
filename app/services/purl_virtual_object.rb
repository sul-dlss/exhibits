# frozen_string_literal: true

# Class to handle determining if a purl is a virtual object and
# returning the thumbnail identifier for it, which is a special case
class PurlVirtualObject
  # @param public_cocina [Hash] the public cocina hash for this Purl object
  # @example
  #   PurlVirtualObject.new(public_cocina: cocina_hash)
  def initialize(public_cocina:)
    @public_cocina = public_cocina
  end

  # @return [Boolean] true if this Purl object is a virtual object, false otherwise
  def virtual_object?
    return false if Array(@public_cocina.dig('structural', 'contains')).present?

    Array(@public_cocina.dig('structural', 'hasMemberOrders')).any? do |resource|
      resource.fetch('members', nil).present?
    end
  end

  # @return [String, nil] the thumbnail identifier for the first member of the virtual object
  def virtual_object_thumbnail_identifier
    return nil unless virtual_object?

    purl_thumbnail
  end

  private

  def purl_thumbnail
    @purl_thumbnail ||= PurlThumbnail.call(purl_object: Purl.new(first_member_druid_of_virtual_object))
  end

  def first_member_druid_of_virtual_object
    Array(@public_cocina.dig('structural', 'hasMemberOrders')).first&.fetch('members', [])&.first
  end
end
