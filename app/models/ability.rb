class Ability
  include Spotlight::Ability
  def initialize(user)
    super

    can :manage, PurlResource, exhibit_id: user.roles.pluck(:exhibit_id) if user
  end
end