Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "dashboard", to: "dashboard#index"

  # ── Authentication ────────────────────────────────────────────
  get  "login",    to: "sessions#new"
  post "login",    to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  # Registration temporarily disabled
  # get  "register", to: "registrations#new"
  # post "register", to: "registrations#create"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # ── Favorites ─────────────────────────────────────────────────
  resources :favorites, only: [:index, :create, :destroy] do
    collection { post :toggle }
  end

  # ── Projects & Tags ──────────────────────────────────────────────
  resources :projects
  resources :tags

  # ── Test Suites, Cases, Results ──────────────────────────────────
  resources :test_suites
  resources :test_cases do
    member { post :run }
  end

  # ── Test Case Manager ──────────────────────────────────────────
  resources :test_case_manager, only: [:index] do
    collection do
      get  :editor
      get  :batch_edit
      patch :batch_update
      get  :export
      get  :import_preview
      post :import_preview
      post :import
      post :clone
    end
  end

  resources :test_results, only: [:index, :show] do
    collection { get :export }
  end
  resources :test_suite_runs, only: [:index, :show]

  # ── Jobs & Workers ───────────────────────────────────────────────
  resources :jobs
  resources :job_runs, only: [:index, :show]
  resources :job_artifacts

  # ── Schedules ────────────────────────────────────────────────────
  resources :schedules do
    member { post :trigger }
  end

  # ── API Tokens ───────────────────────────────────────────────────
  resources :api_tokens

  # ── Issues (nested) ──────────────────────────────────────────────
  resources :issues do
    member do
      patch :reassign
    end
    resources :issue_comments, path: "comments" do
      post "reactions", to: "comment_reactions#create", as: :comment_reactions
      delete "reactions", to: "comment_reactions#destroy", as: :comment_reaction
    end
    resources :issue_attachments, path: "attachments"
  end

  # ── Knowledge Base ──────────────────────────────────────────────
  resources :wiki_pages, path: "wiki"

  # ── Posts ────────────────────────────────────────────────────────
  resources :posts

  # ── Users ────────────────────────────────────────────────────────
  resources :users

  # ── Notifications ────────────────────────────────────────────────
  resources :notifications do
    collection do
      get :unread_count
    end
    member do
      post :mark_read
    end
  end

  # ── Logs ─────────────────────────────────────────────────────────
  resources :logs, only: [:index, :show] do
    member { get :stream }
    resources :log_comments, only: [:create, :destroy]
  end

  # ── Search ───────────────────────────────────────────────────────
  resources :search, only: [:index]

  # ── Bulk Operations ──────────────────────────────────────────────
  post "bulk_operations", to: "bulk_operations#create"

  # ── Cloud Providers & Instances ──────────────────────────────────
  resources :cloud_providers do
    collection { post :ecs_run }
    member { post :sync }
    member { post :verify }
  end
  resources :cloud_instances do
    member do
      post :start
      post :stop
      post :terminate
    end
  end

  # ── Health ───────────────────────────────────────────────────────
  get "health", to: "health#show"

  # ── API ──────────────────────────────────────────────────────────
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
      resources :jobs, only: [:index, :show, :create]
      resources :results, only: [:index, :show]
    end
  end

  # ── Root ─────────────────────────────────────────────────────────
  root "dashboard#index"
end
