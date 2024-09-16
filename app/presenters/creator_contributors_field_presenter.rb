# frozen_string_literal: true

# Convert the name_roles_ssim field data to a human-readable display format.
class CreatorContributorsFieldPresenter < Blacklight::FieldPresenter
  # Convert the name_roles_ssim field data (which is the role followed by the display name) to
  # the name and all the applicable roles.
  # @return [Array<String>] the values of the field
  def values
    @values ||= begin
      roles_by_name = {}

      retrieve_values.map do |value|
        role, name = value.split('|', 2)

        next if name.blank?

        roles_by_name[name] ||= []
        roles_by_name[name] << role if role.present?
      end

      roles_by_name.map do |name, roles|
        if roles.none?
          name
        else
          "#{name} (#{roles.join(', ')})"
        end
      end
    end
  end
end
