# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resources :users
  resources :articles

  resources :blogs, param: :slug do
    collection do
      get :connect
    end
  end

  resources :settings, only: %i[index show]
  resources :storages do
    resources :repos
  end

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
