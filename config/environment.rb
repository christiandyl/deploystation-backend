# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'docker'

class PermissionDenied < StandardError
  def message
    "Error 550, you can't have access to this object."
  end
end

# Initialize the Rails application.
Rails.application.initialize!
