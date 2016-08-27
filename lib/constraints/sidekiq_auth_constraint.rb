module Constraints
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