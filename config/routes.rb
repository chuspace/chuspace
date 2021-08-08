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

  namespace :github do
    resources :repos
  end

  delete '/sessions/:id', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new', as: :login
  get '/auth/email', to: 'sessions#new_email', as: :login_email
end
