# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  delete '/sessions/:id', to: 'sessions#destroy', as: :logout
  get '/auth/:provider/callback', to: 'sessions#create'
end
