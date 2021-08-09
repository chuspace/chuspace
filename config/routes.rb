# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resources :users
  resources :articles
  resources :welcome

  resources :blogs, param: :slug do
    collection do
      get :connect
    end
  end

  namespace :github do
    resources :repos
  end

  resources :settings, only: %i[index show]
  resources :storages, only: %i[create update edit destroy]

  namespace :settings do
    resources :profiles, path: 'profile'
    resources :storages, path: 'storage'
  end

  get '/me', to: 'users#show', as: :profile

  delete '/sessions/:id', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new', as: :login
  get '/auth/email', to: 'sessions#new_email', as: :login_email
end
