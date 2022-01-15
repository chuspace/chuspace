# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index', constraints: RootConstraint.new, as: :authenticated_root
  root to: 'welcome#index'

  resources :auto_checks, only: :create

  namespace :connect do
    root to: 'home#index'

    resources :personal_publications, path: 'personal', param: :git_provider, only: %i[index show create] do
      member do
        get :repos
        get :users
      end

      member do
        get '/*repo_fullname', to: 'personal_publications#new', as: :new
        post '/*repo_fullname', to: 'personal_publications#create', as: :create
      end
    end

    resources :other_publications, path: 'other', param: :git_provider, only: %i[index show create] do
      member do
        get :repos
        get :users
      end

      member do
        get '/*repo_fullname', to: 'other_publications#new', as: :new
        post '/*repo_fullname', to: 'other_publications#create', as: :create
      end
    end
  end

  resources :magic_logins, only: :index, path: 'magic'
  resources :signups, only: %i[index create], path: 'signup' do
    collection do
      get :email
    end
  end

  resources :sessions, only: %i[index create destroy], path: 'login' do
    collection do
      get :email
    end
  end

  delete '/sessions/:id', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'oauths#create'

  namespace :webhooks do
    namespace :github do
      resources :repos, only: :create
    end
  end

  resources :git_providers, only: :show do
    resources :repos, only: %i[index create], module: :git_providers
  end

  namespace :git_providers do
    namespace :github do
      resources :callbacks, only: :index, path: 'callback'
    end

    namespace :gitlab do
      resources :callbacks, only: :index, path: 'callback'
    end
  end

  resources :users, path: '', except: :index, param: :username do
    resources :publications, path: '', only: :show, param: :permalink do
      resources :settings, only: %i[index show update], controller: :publication_settings

      scope constraints: { path: /[^\0]+/ }, format: false do
        scope controller: :drafts, module: :publications do
          get '/drafts/*path', action: :show, as: :draft
          get '/new/*path', action: :new, as: :new_draft
          post '/create/*path', action: :create, as: :create_draft
          get '/edit/*path', action: :edit, as: :edit_draft
          put '/update/*path', action: :update, as: :update_draft
          delete '/delete/*path', action: :update, as: :delete_draft
          post '/publish/*path', action: :preview, as: :publish_draft
          post '/preview/*path', action: :preview, as: :preview_draft
        end
      end

      resources :posts, path: '', except: :index, param: :permalink do
        resources :settings, only: %i[index show]
        resources :revisions, only: %i[index new create]
        resources :editions, only: %i[index new create]
      end
    end
  end
end
