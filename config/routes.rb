Exhibits::Application.routes.draw do
  mount Spotlight::Resources::Iiif::Engine, at: 'spotlight_resources_iiif'
  mount Blacklight::Oembed::Engine, at: 'oembed'

  root to: 'spotlight/exhibits#index'

  devise_for :users, skip: [:sessions]
  devise_scope :user do
    get 'users/auth/webauth' => 'login#login', as: :new_user_session
    match 'users/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end

  resource :purl_resources
  resources :delayed_jobs

  mount Spotlight::Engine, at: '/'
  mount Spotlight::Dor::Resources::Engine, at: '/'
  blacklight_for :catalog
end
