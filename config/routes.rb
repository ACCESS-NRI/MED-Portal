Rails.application.routes.draw do

  resources :editors
  resources :invitations, only: [:index] do
    put 'expire', on: :member
  end
  resources :models do
    resources :votes, only: [:create]
    resources :notes, only: [:create, :destroy]

    member do
      post 'start_review'
      post 'start_meta_review'
      post 'reject'
      post 'withdraw'
    end

    collection do
      get 'recent'
      get 'published', to: 'models#popular'
      get 'active'
      get 'filter', to: 'models#filter'
      get 'search', to: 'models#search'
    end
  end

  resources :onboardings, only: [:index, :create, :destroy] do
    member do
      post :resend_invitation
    end
    collection do
      get :pending
      get 'editor/:token', action: :editor, as: :editor
      post :add_editor
      post :accept_editor
      post :invite_to_editors_team
    end
  end

  get '/aeic/', to: "aeic_dashboard#index", as: "aeic_dashboard"
  get '/editors/lookup/:login', to: "editors#lookup"
  get '/models/lookup/:id', to: "models#lookup"
  get '/models/in/:language', to: "models#filter", as: 'models_by_language'
  get '/models/by/:author', to: "models#filter", as: 'models_by_author'
  get '/models/edited_by/:editor', to: "models#filter", as: 'models_by_editor'
  get '/models/reviewed_by/:reviewer', to: "models#filter", as: 'models_by_reviewer'
  get '/models/tagged/:tag', to: "models#filter", as: 'models_by_tag'
  get '/models/issue/:issue', to: "models#filter", as: 'models_by_issue'
  get '/models/volume/:volume', to: "models#filter", as: 'models_by_volume'
  get '/models/year/:year', to: "models#filter", as: 'models_by_year'
  get '/models/:id/status.svg', to: "models#status", format: "svg", as: 'status_badge'
  get '/models/:doi/status.svg', to: "models#status", format: "svg", constraints: { doi: /10.21105\/joss\.\d{5}/}
  get '/models/:doi', to: "models#show", constraints: { doi: /10.21105\/joss\.\d{5}/}
  get '/models/:doi.:format', to: "models#show", constraints: { doi: /10.21105\/joss\.\d{5}/}

  get '/editor_profile', to: 'editors#profile', as: 'editor_profile'
  patch '/update_editor_profile', to: 'editors#update_profile', as: 'update_editor_profile'

  get '/dashboard/all', to: "home#all"
  get '/dashboard/incoming', to: "home#incoming"
  get '/dashboard/in_progress', to: "home#in_progress"
  get '/dashboard', to: "home#dashboard"

  get '/dashboard/*editor', to: "home#reviews"
  get '/about', to: 'home#about', as: 'about'

  get '/profile', to: 'home#profile', as: 'profile'
  post '/update_profile', to: "home#update_profile"

  get '/auth/:provider/callback', to: 'sessions#create'
  get "/signout" => "sessions#destroy", as: :signout

  get '/blog' => redirect("http://blog.joss.theoj.org"), as: :blog

  # API methods
  post '/models/api_editor_invite', to: 'dispatch#api_editor_invite'
  post '/models/api_start_review', to: 'dispatch#api_start_review'
  post '/models/api_deposit', to: 'dispatch#api_deposit'
  post '/models/api_assign_editor', to: 'dispatch#api_assign_editor'
  post '/models/api_assign_reviewers', to: 'dispatch#api_assign_reviewers'
  post '/models/api_reject', to: 'dispatch#api_reject'
  post '/models/api_withdraw', to: 'dispatch#api_withdraw'
  post '/dispatch', to: 'dispatch#github_receiver', format: 'json'

  root to: 'home#index'
end
