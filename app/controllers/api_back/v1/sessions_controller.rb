module ApiBack
  module V1
    class SessionsController < ActionController::API

      def create
        connect = user = nil

        Connect::SUPPORTED_CONNECTS.each do |c|
          data = params["connect_#{c}"]
          if data
            connect = Connect::class_for(c).authenticate(data)
            user = connect.user if connect
            raise "Invalid credentials" if user.nil?
            break
          end
        end

        token = Token.new user
        token.generate_token

        render json: {success: true, auth_token: token.token, expires: token.expires, result: user}
      end

    end
  end
end