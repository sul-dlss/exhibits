##
# CanCan authorization evaluation model
class Ability
  include Spotlight::Ability
  def initialize(user)
    user ||= Spotlight::Engine.user_class.new

    super(user)

    can :manage, Delayed::Job if user.superadmin?

    can :manage, DorHarvester, exhibit_id: user.exhibit_roles.pluck(:resource_id)

    # disable spotlight functionality we don't want to expose in spotlight:

    # disable exhibit import/export
    cannot :import, Spotlight::Exhibit unless user.superadmin?

    cannot :manage, Spotlight::Filter unless user.superadmin?
  end
end
