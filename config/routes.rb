# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resources :users, path: 'u'

  resources :auto_checks, only: :create
  resources :setups, only: %i[index show], path: 'get-started'

  resources :blogs, path: 'b' do
    resources :blobs, only: :index
    resources :domains
    resources :articles do
      resources :commits, only: :new
    end

    collection do
      get :connect
    end
  end

  resources :storages do
    resources :repos
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


  resources :webhooks, only: :create

  delete '/sessions/:id', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'oauths#create'
  get '/:id', to: 'users#show', as: :profile
end
