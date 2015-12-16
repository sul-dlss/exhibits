# :nodoc:
class User < ActiveRecord::Base
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

  private

  # rubocop:disable Metrics/MethodLength
  def create_roles_from_workgroups
    return if superadmin?

    role_attributes = {
      resource: Spotlight::Site.instance,
      role: ('admin' if (webauth_groups & Settings.superadmin_workgroups).any?)
    }

    return unless role_attributes[:role].present?

    if persisted?
      roles.create role_attributes
    else
      roles.build role_attributes
    end
  end
  # rubocop:enable Metrics/MethodLength
end
