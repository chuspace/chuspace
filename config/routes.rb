# frozen_string_literal: true

Rails.application.routes.draw do
  get 'users/edit'
  get 'users/update'
  get 'users/destroy'
  root to: 'home#index'

  resources :users
  resources :articles

  resources :blogs, param: :slug do
    collection do
      get :connect
    end
  end

  namespace :github do
    resources :repos
  end

  get '/me', to: 'users#show', as: :profile

  delete '/sessions/:id', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new', as: :login
  get '/auth/email', to: 'sessions#new_email', as: :login_email
end
