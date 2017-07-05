Exhibits::Application.routes.draw do
  # API compatible with is_it_working checks
  match "/is_it_working" => "ok_computer/ok_computer#index", via: [:get, :options]
  mount OkComputer::Engine, at: "/status"

  authenticate :user, lambda { |u| u.superadmin? } do
    require 'sidekiq/web'
    Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'

  root to: 'spotlight/exhibits#index'

  devise_for :users, skip: [:sessions]
  devise_scope :user do
    get 'users/auth/webauth' => 'login#login', as: :new_user_session
    match 'users/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end

  resource :purl_resources

  mount Blacklight::Engine => '/'
  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog'

  mount Spotlight::Engine, at: '/'

  resources :exhibits, path: '/', only: [] do
    resource :dor_harvester, controller: :"dor_harvester", only: [:create, :update]
    resource :services, only: [:create, :edit, :update] do
      member do
        patch 'sync'
      end
    end
    resource :viewers, only: [:create, :edit, :update]
  end

  mount MiradorRails::Engine, at: MiradorRails::Engine.locales_mount_path
end
