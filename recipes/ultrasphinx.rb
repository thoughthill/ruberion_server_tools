# ==========================
# Sphinx Index Tasks
# ==========================


namespace :ultrasphinx do
  
  desc "Check if sphinx daemon is running"
  task :sphinx_status, :roles => :app do
    begin
      invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:status"
    rescue
      puts "Seems like it's not deployed yet, skip"
    end
  end

  desc "Ultrasphinx Bootstrap"
  task :bootstrap, :roles => :app do    
    if using_ultrasphinx?
      invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:bootstrap"
    else
      puts "Enable ultrasphinx on deploy.rb first."
    end
  end

  desc "Update Index"
  task :index, :roles => :app do
    if using_ultrasphinx? && ultrasphinx_configured?
      invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:index"
    else
      puts "Enable ultrasphinx on deploy.rb or run 'cap config:ultrasphinx_default_base'"
    end
  end

  desc "Configure Sphinx"
  task :configure, :roles => :app do
    if using_ultrasphinx?
      if ultrasphinx_configured?
        invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:configure"
      else
        puts "The file config/ultrasphinx/default.base is missing. Create it first"
        puts " you can run cap config:ultrasphinx_default_base"
      end
    end
  end

  desc "Stop Sphinx daemon"
  task :stop, :roles => :app do
    begin
      result = run_and_return("cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:status")
      if result.match("Daemon is running")
        invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:stop"
      else
        puts "Sphinx daemon Not Running."
      end
    rescue
      puts "Seems like it's not deployed yet, skip"
    end
  end

  desc "Start Sphinx daemon"
  task :start, :roles => :app do
    begin
      result = run_and_return("cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:status")
      if result.match("Daemon is stopped")
        invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:start"
      else
        puts "Sphinx daemon already Running."
      end
    rescue
      puts "Seems like it's not deployed yet, skip"
      puts "maybe you should deploy first or run cap config:ultrasphinx_default_base"
    end
  end

  desc "Restart Sphinx daemon"
  task :restart, :roles => :app do
    begin
      invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:restart"
    rescue
      puts "Seems like it's not deployed yet, skip"
      puts "maybe you should deploy first or run cap config:ultrasphinx_default_base"
    end
  end
end
