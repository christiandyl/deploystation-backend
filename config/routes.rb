Rails.application.routes.draw do

  root :controller => :application, :action => :root

  scope :module => :api_back do
    scope :v1, :module => :v1 do

      resource  :session, :only => [:create]

      resources :users, :only => [:create] do
        member do
          get :events
        end
      end

    end
  end

  scope :module => :api_deploy do
    scope :v1, :module => :v1 do
      
      resources :containers, :only => [:create, :show, :destroy] do
        member do
          post :start
          post :stop
          post :restart
          post :command
        end
      end
    
    end
  end

end
