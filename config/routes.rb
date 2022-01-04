# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'connect_blogs#index', constraints: RootConstraint.new, as: :authenticated_root
  root to: 'home#index'

  resources :auto_checks, only: :create

  scope :connect do
    resources :connect_blogs, path: 'blog', param: :git_provider, only: %i[index show] do
      member do
        get '/:repo_fullname', to: 'connect_blogs#finalise_settings', as: :repo
        post '/:repo_fullname', to: 'connect_blogs#create', as: :create
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
    resources :blogs, path: '', only: :show, param: :permalink do
      resources :settings, only: %i[index show]
      resources :posts, path: '', except: :index, param: :permalink do
        resources :settings, only: %i[index show]
        resources :revisions, only: %i[index new create]
        resources :editions, only: %i[index new create]
      end
    end
  end
end
