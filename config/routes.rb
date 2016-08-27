Rails.application.routes.draw do
  root :controller => :application, :action => :root

  extend ApiRoutes if Settings.api.enabled
  extend AdminRoutes if Settings.backoffice.enabled
end
