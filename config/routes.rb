# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index', constraints: RootConstraint.new, as: :authenticated_root
  root to: 'welcome#index'

  resources :auto_checks, only: :create

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

  resources :users, path: '', except: :index, param: :username, constraints: UserConstraint.new do
    resources :settings, only: %i[index show update], module: :users
  end

  resources :publications, only: :index
  resources :publications, path: '', only: :show, param: :permalink, constraints: PublicationConstraint.new do
    resources :settings, only: %i[index show update], module: :publications

    resources :people, path: 'people', only: %i[index show update destroy], module: :publications do
      collection { get :autocomplete }
      collection { get :pending }
    end

    resources :invites, only: %i[new create], module: :publications do
      collection { get :accept }
    end

    scope constraints: { path: /[^\0]+/ }, format: false do
      scope controller: :assets, module: :publications do
        get '/asset/*path', action: :show, as: :asset
        post '/assets', action: :create, as: :assets
        delete '/delete/*path', action: :destroy, as: :delete_asset
      end
    end

    scope constraints: { path: /[^\0]+/ } do
      scope controller: :drafts, module: :publications do
        get '/drafts', action: :index, as: :drafts_root
        get '/drafts/*path', action: :index, as: :drafts
        get '/new', action: :new, as: :new_draft
        post '/create', action: :create, as: :create_draft
        get '/*path/edit', action: :edit, as: :edit_draft
        patch '/*path/update', action: :update, as: :update_draft
        delete '/*path/delete', action: :destroy, as: :delete_draft

        scope controller: :previews, module: :drafts do
          get '/*path/preview', action: :show, as: :preview_draft
        end

        scope controller: :publishings, module: :drafts do
          get '/*path/publish', action: :new, as: :new_publish_draft
          post '/*path/publish', action: :create, as: :publish_draft
        end

        scope controller: :commits, module: :drafts do
          get '/*path/commit', action: :new, as: :new_commit_draft
          post '/*path/commit', action: :create, as: :commit_draft
        end

        scope controller: :diffs, module: :drafts do
          get '/*path/diff', action: :new, as: :new_draft_diff
        end

        scope controller: :autosaves, module: :drafts do
          post '/*path/autosave', action: :create, as: :autosave_draft
        end
      end
    end

    resources :posts, path: '', except: :index, param: :permalink do
      resources :settings, only: %i[index show]
    end
  end
end
