module BackOffice
  extend ActiveSupport::Concern

  def admin_login
    if request.post?
      permit = [:email, :password, :remember_me]
      partner_data = params.require(:login).permit(permit).to_h

      @email = partner_data[:email]

      if partner_data.include?(:remember_me)
        partner_data.delete(:remember_me)
        remember_me = true
      else
        remember_me = false
      end

      # Authorizing user
      connect = Connects::Login.authenticate(partner_data)

      unless connect.nil?
        # Getting user entity
        user = connect.user
        if user.role?('admin')
          period = remember_me ? 2.days : 2.hours
          session_time = period.from_now.to_i

          (token = Token.new(user)).generate_token

          cookies[:auth_token] = token.token

          redirect_to admin_root_path
        else
          @error = "Invalid credentials"
        end
      else
        @error = "Invalid credentials"
      end
    end
  end

  def admin_logout
    cookies[:auth_token] = nil

    redirect_to admin_login_path
  end

  def authenticate_admin_user!
    if cookies[:auth_token].nil?
      redirect_to admin_login_path

      return false
    else
      auth_token = cookies[:auth_token]
      (token = ::Token.new(auth_token)).decode_token

      @current_user = token.find_user

      if !@current_user.nil? && @current_user.role?(:admin)
        return true
      else
        admin_logout
        return false
      end
    end
  end

  def current_admin_user
    @current_user
  end
end
