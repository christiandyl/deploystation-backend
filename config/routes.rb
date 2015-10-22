Rails.application.routes.draw do

  root :controller => :application, :action => :root

  namespace :v1 do
    
    resources :containers, :only => [:create, :show, :destroy] do
      member do
        post :start
        post :stop
        post :restart
      end
    end
    
  end

end
