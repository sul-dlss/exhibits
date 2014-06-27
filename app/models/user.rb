class User < ActiveRecord::Base
  include Spotlight::User
  
  # Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :remote_user_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
  
  def webauth_groups= groups
    g = groups.split("|")
    
    if g.include? "dlss:exhibits-admin" and !superadmin?
      roles.create!(exhibit: nil, role: 'admin')
    end
  end
end
