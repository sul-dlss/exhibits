Exhibits::Application.routes.draw do
  # API compatible with is_it_working checks
  match "/is_it_working" => "ok_computer/ok_computer#index", via: [:get, :options]
  mount OkComputer::Engine, at: "/status"

  authenticate :user, lambda { |u| u.superadmin? } do
    require 'sidekiq/web'
    require 'sidekiq/pro/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :exhibit_finder, only: %i[show index]

  scope '(:locale)', locale: Regexp.union(Spotlight::Engine.config.i18n_locales.keys.map(&:to_s)), defaults: { locale: nil } do
    mount Blacklight::Oembed::Engine, at: 'oembed'
    mount Riiif::Engine => '/images', as: 'riiif'

    root to: 'spotlight/exhibits#index'

    devise_for :users, skip: [:sessions]
    devise_scope :user do
      get 'users/auth/sso' => 'login#login', as: :new_user_session
      match 'users/sign_out' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
    end

    resource :purl_resources

    concern :searchable, Blacklight::Routes::Searchable.new
    # This should be switched back to RangeSearchable when blacklight_range_limit removes the deprecated 'range_limit_panel/:id' route.
    concern :range_searchable, BlacklightRangeLimit::Routes::ExhibitsRangeSearchable.new

    # this has to come before the Blacklight + Spotlight routes to avoid getting routed as
    # a document request.
    resources :exhibits, path: '/', only: [] do
      resource :catalog, only: [], as: 'catalog', controller: 'spotlight/catalog' do
        concerns :range_searchable
      end

      resource :home, only: [], as: 'home', controller: 'spotlight/home_pages' do
        concerns :range_searchable
      end
    end

    resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog'
    resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
      concerns :searchable
      concerns :range_searchable
    end

    resource :search_across, only: [:index], path: '/search', controller: 'search_across' do
      concerns :searchable
      concerns :range_searchable
    end

    concern :exportable, Blacklight::Routes::Exportable.new

    resources :exhibits, path: '/', only: [] do
      resource :dor_harvester, controller: :"dor_harvester", only: [:create, :update] do
        resources :index_statuses, only: [:index, :show]
      end
      resource :bibliography_resources, only: [:create, :update]
      resource :viewers, only: [:create, :edit, :update]

      resources :solr_documents, only: [], path: '/catalog', controller: 'spotlight/catalog' do
        concerns :exportable

        member do
          get 'metadata' => 'metadata#show'
        end
      end
    end
  end

  Blacklight::Engine.routes.default_scope = { path: "(:locale)", locale: Regexp.union(Spotlight::Engine.config.i18n_locales.keys.map(&:to_s)), module: 'blacklight', defaults: { locale: nil } }
  mount Blacklight::Engine => '/'
  Spotlight::Engine.routes.default_scope = { path: "(:locale)", locale: Regexp.union(Spotlight::Engine.config.i18n_locales.keys.map(&:to_s)), module: 'spotlight', defaults: { locale: nil } }
  mount Spotlight::Engine, at: '/'
end
