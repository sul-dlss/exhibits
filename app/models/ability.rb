##
# CanCan authorization evaluation model
class Ability
  include Spotlight::Ability
  def initialize(user)
    super

    can :manage, PurlResource, exhibit_id: user.roles.pluck(:exhibit_id) if user

    # disable spotlight functionality we don't want to expose in spotlight:

    # disable exhibit import/export
    cannot :import, Spotlight::Exhibit unless user && user.superadmin?

    # disable exhibit multi-tenancy.
    cannot :create, Spotlight::Exhibit
  end
end
