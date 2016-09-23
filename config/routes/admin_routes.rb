# require 'constraints/sidekiq_auth_constraint'
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

module AdminRoutes
  def self.extended(router)
    router.instance_exec do
      ActiveAdmin.routes(self)
      get 'admin/login', to: 'application#admin_login'
      post 'admin/login', to: 'application#admin_login'
      get 'admin/logout', to: 'application#admin_logout'
      constraints lambda { |request| SidekiqAuthConstraint.admin?(request) } do
        mount Sidekiq::Web => '/admin/sidekiq'
      end
      get '/admin/sidekiq', to: redirect('admin/login')
    end
  end
end
