Proiel::Application.routes.draw do
  get "help/index"

  devise_for :users
  resources :users, :except => [:create, :update, :destroy, :new, :edit]

  resource :profile, :only => [:edit, :update]

  # resources :audits, :only => [:index, :destroy]

  resources :sources, :except => [:destroy]

  resources :source_divisions, :only => [:show, :new, :create, :edit, :update] do
    resource :discourse
  end

  resources :semantic_relations, :only => [:show, :edit, :update]

  #resources :alignments, :only => [:show, :edit] do
  #  member do
  #    post :commit
  #    post :uncommit
  #  end
  #end

  resources :lemmata, :except => [:create, :destroy, :new] do
    member do
      post :merge
    end
  end

  resources :tokens, :except => [:create, :destroy, :new] do
    member do
      get :dependency_alignment_group
    end
    get :quick_search, on: :collection
    get :opensearch, on: :collection
  end

  resources :sentences, :only => [:show, :new, :create, :edit, :update] do
    member do
      get :merge
      get :tokenize
      get :resegment_edit
      get :flag_as_not_reviewed # FIXME: should be post
      get :flag_as_reviewed     # FIXME: should be post
      get :export
    end

    resource :dependency_alignments, :only => [:show, :edit, :update]

    resource :morphtags, :only => [:edit, :update] do
      member do
        post :auto_complete_for_morphtags_lemma
      end
    end

    resource :dependencies, :only => [:show, :edit, :update]

    resource :info_status, :only => [:edit, :update] do
      collection do
        post :delete_contrast
        post :delete_prodrop
      end
    end

    resource :tokenizations, :only => [:edit, :update]
  end

  resources :notes, :only => [:show, :edit, :update, :destroy]

  resources :semantic_tags, :except => [:create, :update, :destroy, :new, :edit]

  resource :help, :except => [:show, :create, :update, :destroy, :new, :edit] do
    member do
      get :ack, controller: 'help'
      get :ss, controller: 'help'
    end
  end

  # Wizard
  # match '/wizard/:action', :to => 'wizard#:action'
  # match '/wizard',         :to => 'wizard#index'

  # Quick search and search suggestions
  get '/quick_search', :to => 'tokens#quick_search'
  get '/quick_search.:format', :to => 'tokens#quick_search'
  get '/opensearch.:format', :to => 'tokens#opensearch'

  # Default page
  root :to => 'help#index'
end
