# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resources :auto_checks, only: :create

  scope :new do
    get '/blog', to: 'blogs#new', as: :new_blog
    get '/blog/:git_provider', to: 'blogs#new', as: :new_blog_git_provider
    get '/blog/:git_provider/:repo_fullname', to: 'blogs#new', as: :new_blog_git_provider_repo
  end

  scope :connect do
    get '/blog', to: 'blogs#connect', as: :connect_blog
    get '/blog/:git_provider', to: 'blogs#connect', as: :connect_blog_git_provider
    get '/blog/:git_provider/:repo_fullname', to: 'blogs#connect', as: :connect_blog_git_provider_repo
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
    resources :blogs, path: '', except: :index, param: :permalink do
      resources :settings, only: %i[index show]
      resources :posts, path: '', except: :index do
        resources :settings, only: %i[index show]
      end
    end
  end
end
