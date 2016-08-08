# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'docker'

class PermissionDenied < StandardError
  def message
    "Error 550, you can't have access to this object."
  end
end

class CustomError < StandardError
  attr_accessor :code, :description, :additional_data

  def initialize(**args)
    self.code = args[:code]
    self.description = args[:description]
    self.additional_data = args[:additional_data] || {}
    message = "code: #{code}, description: #{description}"

    super(message)
  end

  def to_api
    h = {
      code: code,
      description: description
    }.merge(additional_data)

    h
  end
end

# Initialize the Rails application.
Rails.application.initialize!
