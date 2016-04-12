# Change to match your CPU core count
workers_count = ENV['PUMA_WORKERS'] || 3
workers workers_count

# Min and Max threads per worker
threads 1, 6

app_dir = File.expand_path("/var/www/api.deploystation.com/current", __FILE__)
shared_dir = "#{app_dir}/tmp"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/sockets/puma.state"
activate_control_app "unix://#{shared_dir}/sockets/pumactl.sock"

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end