class Role < ActiveRecord::Base
  ROLE_ADMIN = 'admin'.freeze

  belongs_to :user
end
