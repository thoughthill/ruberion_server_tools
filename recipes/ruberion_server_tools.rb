class Capistrano::Configuration

  ##
  # Print an informative message with asterisks.
  def inform(message)
    puts "#{'*' * (message.length + 4)}"
    puts "* #{message} *"
    puts "#{'*' * (message.length + 4)}"
  end

  ##
  # Read a file and evaluate it as an ERB template.
  # Path is relative to this file's directory.

  def render_erb_template(filename)
    template = File.read(filename)
    result   = ERB.new(template).result(binding)
  end

  ##
  # Run a command and return the result as a string.
  #
  # TODO May not work properly on multiple servers.

  def run_and_return(cmd)
    output = []
    run cmd do |ch, st, data|
      output << data
    end
    return output.to_s
  end
  
  def ultrasphinx_configured?
    result = run_and_return("ls -al #{shared_path}/config/ultrasphinx/")
    if result.match("default.base")
      return true
    else
      return false
    end
  end

end

### CONFIG Tasks that suits us ###
namespace :config do
  
  desc "Create Mysql database" 
  task :create_mysql_db do
    result = run_and_return("mysql -u root -e 'show databases;'")
    if result.match(production_db)
      inform "Database #{production_db} already exists."
    else
      inform "Database does not exist, Going to create Mysql Database now"
      run "mysqladmin -u #{mysql_user} create #{production_db}"
    end
  end

  desc "Create shared folders."
  task :shared_config do
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/sessions"
    run "mkdir -p #{shared_path}/index" if using_ferret?
    if using_ultrasphinx?
      run "mkdir -p #{sphinx_db_path}"
      run "mkdir -p #{shared_path}/config/ultrasphinx"
      run "mkdir -p #{sphinx_db_path}/#{rails_env}"
    end
  end
  
  desc "Create memcached.yml"
  task :memcached_yml, :roles => :app do
    result = run_and_return("ls #{shared_path}/config")
    if result.match(/memcached\.yml/)
      inform "memcached.yml already exists."
    else
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/memcached.yml.erb")
      put contents, "#{shared_path}/config/memcached.yml"
      inform "memcached.yml copied succesfully."
    end
  end

  desc "Create database.yml"
  task :database_yml do
    result = run_and_return("ls #{shared_path}/config")
    if result.match(/database\.yml/)
      inform "database.yml already exists."
    else
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/database.yml.erb")
      put contents, "#{shared_path}/config/database.yml"
      inform "database.yml copied succesfully."
    end
  end

  desc "Setup Nginx vhost config"
  task :create_nginx_conf, :roles => :app do
    result = run_and_return("ls #{shared_path}/config")
    if result.match(/nginx\.conf/)
      inform "nginx.conf already exists."
    else
      result = render_erb_template(File.dirname(__FILE__) + "/templates/nginx.vhost.conf.erb")
      put result, "/tmp/nginx.vhost.conf"
      run "cp /tmp/nginx.vhost.conf #{shared_path}/config/nginx.conf"
      inform "You must edit /etc/nginx/nginx.conf to include the vhost config file."
    end
  end

  desc "Create mongrel_cluster.yml."
  task :mongrel_cluster_yml do
    result = run_and_return("ls #{shared_path}/config")
    if result.match(/mongrel_cluster\.yml/)
      inform "mongrel_cluster.yml alread exists."
    else
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/mongrel_cluster.yml.erb")
      put contents, "#{shared_path}/config/mongrel_cluster.yml"
      inform "mongrel_cluster.yml copied succesfully."
    end
  end
  
  desc "Create default.base for Ultrasphinx"
  task :ultrasphinx_default_base do
    result = run_and_return("ls #{shared_path}/config/ultrasphinx")
    if result.match(/default\.base/)
      inform "default.base already exists."
    else
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/default.base.erb")
      put contents, "#{shared_path}/config/ultrasphinx/default.base"
      inform "default.base copied succesfully."
    end
  end
  
  desc "Create juggernaut_config.yml"
  task :create_juggernaut_config_yml do
    result = run_and_return("ls #{shared_path}/config/")
    if result.match(/juggernaut_config\.yml/)
      inform "juggernaut_config.yml already exists, delete it first."
    else
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/juggernaut_config.yml.erb")
      put contents, "#{shared_path}/config/juggernaut_config.yml"
      inform "juggernaut_config.yml copied succesfully."
    end
  end
  
  desc "Create ferret_server.yml"
  task :create_ferret_server_yml do
    result = run_and_return("ls #{shared_path}/config/")
    if result.match(/ferret_server\.yml/)
      inform "ferret_server.yml already exists, delete it first."
    else
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/ferret_server.yml.erb")
      put contents, "#{shared_path}/config/ferret_server.yml"
      inform "ferret_server.yml copied succesfully."
    end
  end

  desc "Main method for creating shared configs"
  task :create_shared_config do
    create_mysql_db
    shared_config
    database_yml
    create_nginx_conf
    mongrel_cluster_yml
    memcached_yml if using_memcached?
    ultrasphinx_index_folders if using_ultrasphinx?
    ultrasphinx_default_base if using_ultrasphinx?
    create_juggernaut_config_yml if using_juggernaut?
    create_ferret_server_yml if using_ferret?
  end

  after "deploy:setup", "config:create_shared_config" 

end


#override some deploy tasks because of mongrel
namespace :deploy do

  desc "override the default so we don't mess with dispatch.cgi or dispatch.fcgi"
  task :restart do
    deploy.mongrel.restart
  end

  desc "Quick Deploy. Only update the current version"
  task :quick_deploy, :roles => :app do
    invoke_command "cd #{current_path} && svn update"
    deploy.mongrel.restart
  end
  
  
  desc "Set the proper permissions for directories and files on the script folder"
  task :after_symlink do
    run(chmod755.collect do |item|
      "chmod -R 755 #{current_path}/#{item}*"
    end.join(" && "))
    run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml" 
    run "ln -nfs #{shared_path}/config/ultrasphinx #{current_path}/config/ultrasphinx" if using_ultrasphinx?
    run "ln -nfs #{shared_path}/config/memcached.yml #{current_path}/config/memcached.yml" if using_memcached?
    run "ln -nfs #{shared_path}/config/ferret_server.yml #{current_path}/config/ferret_server.yml" if using_ferret?
    run "ln -nfs #{shared_path}/config/juggernaut_config.yml #{current_path}/config/juggernaut_config.yml" if using_juggernaut?
    run "ln -nfs #{shared_path}/sessions #{current_path}/tmp/sessions"
    run "ln -nfs #{shared_path}/pids #{current_path}/tmp/pids"
    run "ln -nfs #{shared_path}/log #{current_path}/tmp/log"    
  end

  namespace :mongrel do
    desc "Restart task for mongrel"
    task :restart, :roles => :app, :except => { :no_release => true } do
      deploy.mongrel.stop
      sleep 5
      deploy.mongrel.start
    end

    desc "Stop the mongrel appserver"
    task :stop do
      invoke_command "mongrel_rails cluster::stop --config #{shared_path}/config/mongrel_cluster.yml"
    end

    desc "Start the mongrel appserver"
    task :start do
      invoke_command "mongrel_rails cluster::start --config #{shared_path}/config/mongrel_cluster.yml", :via => run_method
    end
  
  end
  
end

# NGINX Restart Task
namespace :nginx do
  desc "Restart Nginx Daemon"
  task :restart do
    invoke_command "/etc/init.d/nginx restart"
  end
end


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


# ==========================
# ACTS AS FERRET Tasks
# ==========================


namespace :ferret do

  desc "Stop Ferret daemon"
  task :stop, :roles => :app do
    begin
      invoke_command "cd #{current_path} && ./script/ferret_server --environment=#{rails_env} stop"
    rescue
      puts "Seems like it's not running yet, skip"
    end
  end

  desc "Start Ferret daemon"
  task :start, :roles => :app do
    begin
      invoke_command "cd #{current_path} && ./script/ferret_server --environment=#{rails_env} start"
    rescue
      puts "There was an error, could not start"
    end
  end

  desc "Restart Ferret daemon"
  task :restart, :roles => :app do
    stop
    sleep 2
    start
  end
end
