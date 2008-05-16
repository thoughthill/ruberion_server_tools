### Tasks that genereate config files ###
Capistrano::Configuration.instance(:must_exist).load do

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
  
    desc "Create memcached.yml"
    task :memcached_yml, :roles => :app do
      result = run_and_return("ls #{shared_path}/config")
      if result.match(/memcached\.yml/)
        inform "memcached.yml already exists."
      else
        contents = render_erb_template(File.dirname(__FILE__) + "/../templates/memcached.yml.erb")
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
        contents = render_erb_template(File.dirname(__FILE__) + "/../templates/database.yml.erb")
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
        result = render_erb_template(File.dirname(__FILE__) + "/../templates/nginx.vhost.conf.erb")
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
        contents = render_erb_template(File.dirname(__FILE__) + "/../templates/mongrel_cluster.yml.erb")
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
        contents = render_erb_template(File.dirname(__FILE__) + "/../templates/default.base.erb")
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
        contents = render_erb_template(File.dirname(__FILE__) + "/../templates/juggernaut_config.yml.erb")
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
        contents = render_erb_template(File.dirname(__FILE__) + "/../templates/ferret_server.yml.erb")
        put contents, "#{shared_path}/config/ferret_server.yml"
        inform "ferret_server.yml copied succesfully."
      end
    end
  
    desc "Create mod_rails vhost"
    task :create_mod_rails_vhost do
      name = application.gsub('.', '_')
      result = run_and_return("ls /etc/apache2/vhosts.d")
      if result.match(name)
        inform "/etc/apache2/vhosts.d/#{name}.conf already exist"
      else
        contents = render_erb_template(File.dirname(__FILE__) + "/../templates/mod_rails.conf.erb")
        put contents, "/etc/apache2/vhosts.d/#{name}.conf"
        inform "The file /etc/apache2/vhosts.d/#{name}.conf writen succesfully."
      end
    end

    desc "Main method for creating shared configs"
    task :create_shared_config do
      create_mysql_db
      database_yml
      create_nginx_conf
      mongrel_cluster_yml
      memcached_yml if enable_memcached?
      ultrasphinx_default_base if enable_ultrasphinx?
      create_juggernaut_config_yml if enable_juggernaut?
      create_ferret_server_yml if enable_ferret?
    end

    after "deploy:setup", "config:create_shared_config" 

  end

end
