# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'docker'

class PermissionDenied < StandardError
  def message
    "Error 550, you can't have access to this object."
  end
end

class CustomError < StandardError
  attr_accessor :code, :description

  def initialize(**args)
    self.code = args[:code]
    self.description = args[:description]
    message = "code: #{code}, description: #{description}"

    super(message)
  end

  def to_api
    h = {
      code: code,
      description: description
    }

    h
  end
end

# Initialize the Rails application.
Rails.application.initialize!
