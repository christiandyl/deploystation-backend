module ApiBack
  module V1
    class UsersController < ActionController::API

      def create
        connect = user = nil

        Connect::SUPPORTED_CONNECTS.each do |c|
          data = params["connect_#{c}"]
          if data
            connect = Connect::class_for(c).new(data)
            user = connect.user
            break
          end
        end

        raise "Connect is absent" if connect.nil?

        if user.nil?
          user = connect.user = User.create email: connect.get_email
          connect.save!
        end

        token = Token.new user
        token.generate_token

        render json: {success: true, auth_token: token.token, expires: token.expires, result: {}}
      end

      def events

      end

    end
  end
end