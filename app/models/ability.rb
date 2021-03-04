# frozen_string_literal: true

##
# CanCan authorization evaluation model
class Ability
  include Spotlight::Ability
  def initialize(user)
    user ||= Spotlight::Engine.user_class.new

    super(user)

    can :manage, DorHarvester, exhibit_id: user.exhibit_roles.pluck(:resource_id)

    # We're doing this temporarily until spotlight#1752 is solved (which may just end up doing this)
    can :create, Spotlight::FeaturedImage if user.roles.any?

    can :manage, Viewer, exhibit_id: user.exhibit_roles.pluck(:resource_id)

    # disable spotlight functionality we don't want to expose in spotlight:

    # disable exhibit import/export
    cannot :import, Spotlight::Exhibit unless user.superadmin?

    cannot :manage, Spotlight::Filter unless user.superadmin?

    cannot :bulk_update, Spotlight::Exhibit unless user.superadmin?
  end
end
