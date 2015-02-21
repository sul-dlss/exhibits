SulExhibitsTemplate::Application.routes.draw do
  mount Blacklight::Oembed::Engine, at: 'oembed'
  spotlight_root
#  root :to => "catalog#index" # replaced by spotlight_root

  devise_for :users, skip: [:sessions]
  devise_scope :user do
    get "users/auth/webauth" => "login#login", as: :new_user_session
    match 'users/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end

  resource :purl_resources

  mount Spotlight::Engine, at: '/'
  blacklight_for :catalog

end
