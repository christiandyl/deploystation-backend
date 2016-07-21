if Settings.backoffice.enabled
  require 'sidekiq/web'
  class SidekiqAuthConstraint
    def self.admin?(request)
      if request.cookies['auth_token'].nil?
        return false
      else
        auth_token = request.cookies['auth_token']
        (token = ::Token.new(auth_token)).decode_token
        user = token.find_user
        return (!user.nil? && user.role?(:admin))
      end
    end
  end
end

Rails.application.routes.draw do
  if Settings.backoffice.enabled
    ActiveAdmin.routes(self)
    get 'admin/login', to: 'application#admin_login'
    post 'admin/login', to: 'application#admin_login'
    get 'admin/logout', to: 'application#admin_logout'
    constraints lambda { |request| SidekiqAuthConstraint.admin?(request) } do
      mount Sidekiq::Web => '/admin/sidekiq'
    end
    get '/admin/sidekiq', to: redirect('admin/login')
  end

  root :controller => :application, :action => :root

  get "v1/client_settings", :controller => :application, :action => :v1_client_settings

  scope :module => :api do
    scope :v1, :module => :v1 do

      resource :session, :only => [:create]
      resources :users, :only => [:create, :update] do
        put    :avatar, :action => :avatar_update
        delete :avatar, :action => :avatar_destroy
        
        resources :connects, :only => [:index, :create, :destroy]
      end
      get "users/me", :controller => :users, :action => :me
      post "users/request_password_recovery", :controller => :users, :action => :request_password_recovery
      post "user/confirmation", :controller => :users, :action => :confirmation
      post "user/request_email_confirmation", :controller => :users, :action => :request_email_confirmation

      get 'payments/credits_sets', to: 'payments#credits_sets'
      get 'payments/braintree_client_token', to: 'payments#client_token'
      resources :payments, :only => [:index, :create]
      
      resources :devices, :only => [:create, :destroy]

      resources :containers, :only => [:index, :create, :update, :show, :destroy] do
        member do
          post :start
          post :stop
          post :reset
          post :restart
          post :execute_command
          post :invitation
          get  :command
          get  :commands
          get  :players_online
          get  :logs
          get  :referral_token
          post :request_plan
          
          resource :config, :only => [:show, :update]
          resources :plugins, :only => [:index] do
            post :enable
            delete :disable
          end
        end
        resources :accesses, :only => [:index, :create, :destroy]
        resources :bookmarks, :only => [:create, :destroy]
      end
      get :shared_containers, :controller => :containers, :action => :shared
      get :bookmarked_containers, :controller => :containers, :action => :bookmarked
      get :popular_containers, :controller => :containers, :action => :popular
      get :search_containers, :controller => :containers, :action => :search
      
      resources :hosts, :only => [:index]
      resources :plans, :only => [:index]
      resources :games, :only => [:index] do
        get :random_name
        get :check_availability
      end

    end
  end

end
