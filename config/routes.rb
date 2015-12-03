Rails.application.routes.draw do

  root :controller => :application, :action => :root

  scope :module => :api_back do
    scope :v1, :module => :v1 do

      resource :session, :only => [:create]
      resources :users, :only => [:create]
      get "users/me", :controller => :users, :action => :me
      
      resource :connect do
        member do
          post :check
          get  :request_token
        end
      end

    end
  end

  scope :module => :api_deploy do
    scope :v1, :module => :v1 do
      
      resources :containers, :only => [:index, :create, :show, :destroy] do
        member do
          post :start
          post :stop
          post :restart
          post :command
          get  :commands
        end
      end
      
      resources :hosts, :only => [:index]
      resources :games, :only => [:index]
    
    end
  end

end
