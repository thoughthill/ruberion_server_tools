# SERVER VARIABLES, good for debugging
Capistrano::Configuration.instance(:must_exist).load do
  desc "Display Env Variables"
  namespace :env do
    
    lines = "---------------------------------------------------------------------"
    
    desc "Environment Variables on the Server"
    task :printenv do
      puts "Remote Env Variables:"
      puts lines
      stream "printenv"
      puts lines
    end

    desc "Local Variables setup"
    task :list do
      puts lines
      puts "Main Variables"
      puts "  deploy_to_server    : production" if ENV["production"]
      puts "  deploy_to_server    : staging" if ENV["staging"]
      puts "  webserver1          : #{webserver1}"
      puts "  rails_env           : #{rails_env}"
      puts "  deploy_to           : #{deploy_to}"
      puts "  user                : #{user}"
      puts "  use_sudo            : #{use_sudo}"
      puts "  deploy_method       : #{deploy_method}"
      puts lines
      puts "Plugin Extenstions"
      puts "  enable_memcached    : #{enable_memcached?}"
      puts "  enable_ferret       : #{enable_ferret?}"
      puts "  enable_push_server  : #{enable_push_server?}"
      puts "  enable_juggernaut   : #{enable_juggernaut?}"
      puts "  enable_ultrasphinx  : #{enable_ultrasphinx?}"
      puts lines
      puts "Assets Variables"
      puts "  public_assets       : #{public_assets.join(", ")}"
      puts "  tmp_assets          : #{tmp_assets.join(", ")}"
      puts "  config_assets       : #{config_assets.join(", ")}"
      puts "  chmod755            : #{chmod755.join(", ")}"
      puts lines
      puts "Repository"
      puts "  repository          : #{repository}"
      puts "  scm                 : #{scm}"
      puts "  deploy_via          : #{deploy_via}"
      puts lines
      puts "PATHs"
      puts "  shared_path         : #{shared_path}"
      puts "  current_path        : #{current_path}"
      puts lines
      puts "Mongrel:"
      puts "  enabled             : #{deploy_method == 'mongrel'}"
      if deploy_method == "mongrel"
        puts "  mongrel_port        : #{mongrel_port}"
        puts "  mongrel_servers     : #{mongrel_servers}"
        puts "  mongrel_pid         : #{mongrel_pid}"
        puts "  mongrel_conf        : #{mongrel_conf}"
      end
      puts lines
      puts "MYSQL Database:"
      puts "  production_db       : #{production_db}"
      puts "  mysql_socket        : #{mysql_socket}"
      puts "  mysql_user          : #{mysql_user}"
      puts "  mysql_password      : #{mysql_password}"
      puts lines
      puts "Ultrasphinx"
      puts "  enable_ultrasphinx  : #{enable_ultrasphinx?}"
      if enable_ultrasphinx?
      puts "  sphinx_use_delta    : #{sphinx_use_delta}"
      puts "  sphinx_db_path      : #{sphinx_db_path}"
      puts "  sphinx_mem_limit    : #{sphinx_mem_limit}"
      puts "  sphinx_server_port  : #{sphinx_server_port}"
      puts "  sphinx_min_word_len : #{sphinx_min_word_len}"
      end
      puts lines
      puts "Domain Names"
      puts "  vhost_domain_names  : #{domain_names.join(', ')}"
      puts lines
      puts "Passenger mod_rails"
      puts "  enabled             : #{deploy_method == 'mod_rails'}"
      if deploy_method == "mod_rails"
        puts "  rails_max_pool_size : #{rails_max_pool_size}"
        puts "  rails_pool_idle_time: #{rails_pool_idle_time}"
        puts lines
      end
    end
  end
  
end