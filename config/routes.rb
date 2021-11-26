# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resources :auto_checks, only: :create
  resources :setups, only: %i[index show], path: 'get-started'

  scope :connect do
    resources :storages, only: :index, path: :storage, as: :connect_storage
    resources :blogs, only: :index, path: :blog, as: :connect_blog
  end

  scope :new do
    resources :blogs, only: :index, path: :blog, as: :new_blog
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

  resources :users, path: '', param: :username, only: :show do
    resources :blogs, path: '', param: :permalink, only: :show do
      resources :assets, only: :index
      resources :domains

      resources :articles, path: '', param: :permalink do
        resources :commits
      end
    end
  end
end
