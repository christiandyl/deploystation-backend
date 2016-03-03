Rails.application.routes.draw do

  root :controller => :application, :action => :root

  scope :module => :api_back do
    scope :v1, :module => :v1 do

      resource :session, :only => [:create]
      resources :users, :only => [:create, :update] do
        put    :avatar, :action => :avatar_update
        delete :avatar, :action => :avatar_destroy
        
        resources :connects, :only => [:index, :create, :destroy]
      end
      get "users/me", :controller => :users, :action => :me
      post "users/request_password_recovery", :controller => :users, :action => :request_password_recovery

    end
  end

  scope :module => :api_deploy do
    scope :v1, :module => :v1 do
      
      resources :containers, :only => [:index, :create, :update, :show, :destroy] do
        member do
          post     :start
          post     :stop
          post     :restart
          post     :execute_command
          post     :invitation
          get      :command
          get      :commands
          get      :players_online
          get      :logs
          get      :search
          resource :config, :only => [:show, :update]
        end
        resources :accesses, :only => [:index, :create, :destroy]
        resources :bookmarks, :only => [:create, :destroy]
      end
      get :shared_containers, :controller => :containers, :action => :shared
      get :bookmarked_containers, :controller => :containers, :action => :bookmarked
      get :popular_containers, :controller => :containers, :action => :popular
      
      resources :hosts, :only => [:index]
      resources :games, :only => [:index]
    
    end
  end

end
