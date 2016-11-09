class App < Thor

  desc "deploy ENV", "deploy app immediately"
  def deploy(env)
    case env
      when "production"
        git_branch = "master"
      when "staging"
        git_branch = "staging"
      when "beta"
        git_branch = "beta"
      else
        raise "env is incorrect"
    end
    
    commands = [
      "git checkout #{git_branch}",
      "git add --all",
      "git commit -m \"deploy #{Time.now.to_s}\"",
      "git push origin #{git_branch}"
    ]
    
    unless env == "production"
      puts "====================== Deploying latest build (#{env})"
      commands << "cd ../deploystation-devops/mina_back && mina #{env} deploy"
    else
      ["http","worker"].each do |suffix|
        commands << "cd ../deploystation-devops/mina_back && mina production_#{suffix} app:deploy_all"
      end
      commands << "cd ../deploystation-devops/mina_back && mina production_admin deploy"
    end
    
    commands.each do |cmd|
      puts "========== Executing command \"#{cmd}\""
      IO.popen(cmd).each { |l| puts l.chomp }
    end
  end
end