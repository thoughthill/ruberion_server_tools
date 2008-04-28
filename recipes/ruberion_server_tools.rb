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

end

### CONFIG Tasks that suits us ###
namespace :config do
    
  desc "Drop Mysql database" 
  task :drop_mysql_db do
    puts "Are you sure you want to DROP #{production_db}?"
    puts "You have 10 seconds to cancel..."
    sleep 11
    run "mysqladmin -u #{mysql_user} -f drop #{production_db}"
  end
  
  desc "Create Mysql database" 
  task :create_mysql_db do
    inform "Going to create Mysql Database now"
    run "mysqladmin -u #{mysql_user} create #{production_db}"
  end

  desc "Create shared/config."
  task :shared_config do
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/config/ultrasphinx" if ultrasphinx
  end
  
  desc "Create memcached.yml"
  task :memcached_yml, :roles => :app do
    return unless using_memcached?
    # Copy memcached.yml if it doesn't exist.
    result = run_and_return("ls #{shared_path}/config")
    unless result.match(/memcached\.yml/)
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/memcached.yml.erb")
      put contents, "#{shared_path}/config/memcached.yml"
      inform "memcached.yml copied succesfully."
    end
  end

  desc "Create database.yml"
  task :database_yml do
    # Copy database.yml if it doesn't exist.
    result = run_and_return("ls #{shared_path}/config")
    unless result.match(/database\.yml/)
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/database.yml.erb")
      put contents, "#{shared_path}/config/database.yml"
      inform "database.yml copied succesfully."
    end
  end

  desc "Setup Nginx vhost config"
  task :nginx_conf, :roles => :app do
    result = render_erb_template(File.dirname(__FILE__) + "/templates/nginx.vhost.conf.erb")
    put result, "/tmp/nginx.vhost.conf"
    sudo "cp /tmp/nginx.vhost.conf #{shared_path}/config/nginx.conf"
    inform "You must edit /etc/nginx/nginx.conf to include the vhost config file."
  end

  desc "Create mongrel_cluster.yml."
  task :mongrel_cluster_yml do
    # Copy mongrel_cluster.yml if it doesn't exist.
    result = run_and_return("ls #{shared_path}/config")
    unless result.match(/mongrel_cluster\.yml/)
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/mongrel_cluster.yml.erb")
      put contents, "#{shared_path}/config/mongrel_cluster.yml"
      inform "mongrel_cluster.yml copied succesfully."
    end
  end
  
  desc "Create default.base for Ultrasphinx"
  task :ultrasphinx_default_base do
    return unless using_ultrasphinx?
    result = run_and_return("ls #{shared_path}/config/ultrasphinx")
    unless result.match(/default\.base/)
      contents = render_erb_template(File.dirname(__FILE__) + "/templates/default.base.erb")
      put contents, "#{shared_path}/config/ultrasphinx/default.base"
      inform "default.base copied succesfully."
    end
  end

  desc "Main method for creating shared configs"
  task :create_shared_config do
    drop_mysql_db
    create_mysql_db
    shared_config
    database_yml
    nginx_conf
    mongrel_cluster_yml
    memcached_yml if using_memcached?
    ultrasphinx_default_base if using_ultrasphinx?
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
  
  desc "Ultrasphinx Bootstrap"
  task :bootstrap, :roles => :app do
    invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:bootstrap" if using_ultrasphinx?
  end

  desc "Update Index"
  task :index, :roles => :app do
    invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:index" if using_ultrasphinx?
  end

  desc "Configure Sphinx"
  task :configure, :roles => :app do
    invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:configure" if using_ultrasphinx?
  end

  desc "Stop Sphinx daemon"
  task :stop, :roles => :app do
    invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:stop" if using_ultrasphinx?
  end

  desc "Start Sphinx daemon"
  task :start, :roles => :app do
    invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:start" if using_ultrasphinx?
  end

  desc "Restart Sphinx daemon"
  task :restart, :roles => :app do
    invoke_command "cd #{current_path} && RAILS_ENV=#{rails_env} rake ultrasphinx:daemon:restart" if using_ultrasphinx?
  end
end
