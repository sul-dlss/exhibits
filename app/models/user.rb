# frozen_string_literal: true

# :nodoc:
class User < ApplicationRecord
  include ActiveSupport::Callbacks

  define_callbacks :groups_changed

  set_callback :groups_changed, :after, :create_roles_from_workgroups

  include Spotlight::User

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :remote_user_authenticatable, :database_authenticatable,
         :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  attr_reader :webauth_groups

  def webauth_groups=(groups)
    run_callbacks :groups_changed do
      @webauth_groups ||= groups.split('|')
    end
  end

  # Exhibits will populate its own roles from workgroups, and doesn't need
  # this upstream feature.
  def add_default_roles
    # no-op
  end

  private

  def create_roles_from_workgroups
    return if superadmin?

    role_attributes = default_role_attributes

    return if role_attributes[:role].blank?

    if persisted?
      roles.create role_attributes
    else
      roles.build role_attributes
    end
  end

  def default_role_attributes
    {
      resource: Spotlight::Site.instance,
      role: ('admin' if (webauth_groups & Settings.superadmin_workgroups).any?)
    }
  end
end
