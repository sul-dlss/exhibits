##
# CanCan authorization evaluation model
class Ability
  include Spotlight::Ability
  def initialize(user)
    super

    can :manage, Delayed::Job if user && user.superadmin?

    can :manage, PurlResource, exhibit_id: user.exhibit_roles.pluck(:resource_id) if user

    # disable spotlight functionality we don't want to expose in spotlight:

    # disable exhibit import/export
    cannot :import, Spotlight::Exhibit unless user && user.superadmin?
  end
end
