require 'api_deploy/helper'

if Rails.env.staging?
  require 'api_deploy/container_checker_scheduller_worker'
end