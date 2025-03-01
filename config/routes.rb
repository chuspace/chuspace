# frozen_string_literal: true

Rails.application.routes.draw do
  mount Easymon::Engine => '/heartbeat'

  direct :rails_public_blob do |blob|
    if Rails.env.development? || Rails.env.test?
      route =
        if blob.is_a?(ActiveStorage::Variant) || blob.is_a?(ActiveStorage::VariantWithRecord)
          :rails_representation
        else
          :rails_blob
        end
      route_for(route, blob)
    else
      File.join(Rails.application.credentials.app.fetch(:avatar_cdn) { 'https://chuspace.com' }, blob.key)
    end
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessible_entity', via: :all
  match '/406', to: 'errors#unacceptable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  root to: 'home#index'

  resources :auto_checks, only: :create
  resources :topics, only: %i[index show]
  resources :languages, only: %i[index show]

  namespace :connect do
    root to: 'home#index'

    resources :personal_publications, path: 'personal', param: :git_provider, only: %i[index show create] do
      member do
        get :repos
        get :users
      end

      member do
        get '/*repo_fullname', to: 'personal_publications#new', as: :new
        post '/*repo_fullname', to: 'personal_publications#create', as: :create
      end
    end

    resources :other_publications, path: 'other', param: :git_provider, only: %i[index show create] do
      member do
        get :repos
        get :users
      end

      member do
        get '/*repo_fullname', to: 'other_publications#new', as: :new
        post '/*repo_fullname', to: 'other_publications#create', as: :create
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
  match '/auth/:provider/setup', to: 'git_providers#setup', via: %i[get post]
  get '/auth/:provider/callback', to: 'oauths#create'

  namespace :webhooks do
    namespace :github do
      resources :repos, only: :create
    end
  end

  resources :git_providers, only: :show do
    resources :repos, only: %i[index create], module: :git_providers
    resources :oauth_callbacks, only: :index, path: 'callback', module: :git_providers
  end

  resources :users, path: '', only: :show, param: :username, constraints: UserConstraint.new do
    resources :drafts, only: :index, module: :users do
      collection do
        get '/*path', to: 'drafts#index', as: :nested
      end
    end
    resources :posts, only: :index, module: :users
    resources :publications, only: :index, module: :users
  end

  resources :settings, only: %i[index show update]

  resources :publications, path: '', only: :show, param: :permalink, constraints: PublicationConstraint.new do
    resources :settings, only: %i[index show update], module: :publications

    resources :people, path: 'people', module: :publications do
      collection { get :autocomplete }
    end

    resources :invites, only: %i[index new create destroy], module: :publications do
      collection { get :accept }
      member { patch :resend }
    end

    scope constraints: { publication_permalink: /[a-z0-9_\-]+/, path: /[^\0]+/ } do
      scope controller: :assets, module: :publications, format: false do
        get '/assets', action: :index, as: :assets_root
        get '/assets/*path', action: :index, as: :assets
        get '/asset', action: :show, as: :asset, constraints: AssetConstraint.new
        post '/assets', action: :create, as: :create_assets
      end

      scope controller: :drafts, module: :publications, format: false do
        get '/drafts', action: :index, as: :drafts_root
        get '/drafts/*path', action: :index, as: :drafts

        get '/new', action: :new, as: :new_draft
        post '/create', action: :create, as: :create_draft
        get '/*path/edit', action: :edit, as: :edit_draft
        patch '/*path/update', action: :update, as: :update_draft
        delete '/*path/delete', action: :destroy, as: :delete_draft

        scope controller: :publishings, module: :drafts do
          get '/*path/publish', action: :new, as: :new_publish_draft
          post '/*path/publish', action: :create, as: :publish_draft
        end

        scope controller: :commits, module: :drafts do
          get '/*path/commit', action: :new, as: :new_commit_draft
          post '/*path/commit', action: :create, as: :commit_draft
        end

        scope controller: :autosaves, module: :drafts do
          patch '/*path/autosave', action: :update, as: :autosave_draft
        end
      end

      resources :posts, path: '', except: :index, param: :permalink do
        resources :settings, only: %i[index show]
        resources :revisions, module: :posts
        resources :publishings, module: :posts, path: 'editions'
        resources :snippets, module: :posts, only: %i[index show]
      end
    end
  end
end
