module LocalEnv
  module_function

  def load
    env_file = root.join('config', 'local_env.yml')

    YAML.load(File.open(env_file)).each do |key, value|
      ENV[key.to_s] = value
    end if File.exists?(env_file)
  rescue
  end

  def root
    Rails.root || Pathname.new(ENV["RAILS_ROOT"] || Dir.pwd)
  end
end
