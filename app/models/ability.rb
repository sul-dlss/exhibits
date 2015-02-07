class Ability
  include Spotlight::Ability
  def initialize(user)
    super

    can :manage, PurlResource, exhibit_id: user.roles.pluck(:exhibit_id) if user

    # disable exhibit import/export
    cannot :import, Spotlight::Exhibit unless user and user.superadmin?

    # disable exhibit multi-tenancy.
    cannot :create, Spotlight::Exhibit
  end
end