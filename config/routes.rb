Exhibits::Application.routes.draw do
  # API compatible with is_it_working checks
  match "/is_it_working" => "ok_computer/ok_computer#index", via: [:get, :options]
  mount OkComputer::Engine, at: "/status"

  authenticate :user, lambda { |u| u.superadmin? } do
    require 'sidekiq/web'
    Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
    mount Sidekiq::Web => '/sidekiq'
  end

  scope '(:locale)', locale: Regexp.union(Rails.application.config.available_locales) do
    mount Blacklight::Oembed::Engine, at: 'oembed'
    mount Riiif::Engine => '/images', as: 'riiif'

    resources :mirador, only: [:index]

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
    concern :exportable, Blacklight::Routes::Exportable.new

    resources :exhibits, path: '/', only: [] do
      resource :dor_harvester, controller: :"dor_harvester", only: [:create, :update]
      resource :bibliography_resources, only: [:create, :update]
      resource :viewers, only: [:create, :edit, :update]

      resources :solr_documents, only: [], path: '/catalog', controller: 'catalog' do
        concerns :exportable

        member do
          get 'metadata'
        end
      end
    end

    mount MiradorRails::Engine, at: MiradorRails::Engine.locales_mount_path
  end
end
