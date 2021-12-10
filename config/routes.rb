# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resources :auto_checks, only: :create
  resources :setups, only: %i[index show], path: 'get-started'

  scope :connect do
    get '/blog', to: 'blogs#connect', as: :connect_blog
  end

  scope :new do
    get '/storage', to: 'storages#new', as: :new_storage
    get '/blog', to: 'blogs#new', as: :new_blog
  end

  resources :storages, except: :new do
    resources :repositories, only: :index
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

  resources :users, path: '', only: :show, param: :username do
    resources :blogs, path: '', only: %i[show create], param: :permalink do
      resources :settings, only: %i[index show]

      resources :posts, path: '', except: :index do
        resources :settings, only: %i[index show]
        resources :revisions, only: %i[index new]
        resources :editions, only: %i[index new]
      end
    end
  end
end
