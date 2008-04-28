# SERVER VARIABLES, good for debugging
desc "Display Env Variables"
namespace :env do
  task :list do
    lines = "-----------------------------------------------------------------"
    puts lines
    puts "Remote Env Variables:"
    run "printenv"
    puts lines
    puts "Main Variables"
    puts "  Webserver   : #{webserver1}"
    puts "  Rails Env   : #{rails_env}"
    puts "  Deploy to   : #{deploy_to}"
    puts "  Server User : #{user}"
    puts "  Use Sudo    : #{use_sudo}"
    puts "  Using Ultrasphinx: #{using_ultrasphinx?}"
    puts "  Using Memecached : #{using_memcached?}"
    puts "  Using Ferret     : #{using_ferret?}"
    puts lines
    puts "Repository"
    puts "  Repository: #{repository}"
    puts lines
    puts "Shared Path  : #{shared_path}"
    puts "Current Path : #{current_path}"
    puts lines
    puts "Mongrel:"
    puts "  Start Port  : #{mongrel_port}"
    puts "  Servers     : #{mongrel_servers}"
    puts "  PID file    : #{mongrel_pid}"
    puts "  Config File : #{mongrel_conf}"
    puts lines
    puts "Nginx:"
    puts "  domain_names   : #{domain_names.join(', ')}"
    puts lines
    puts "MYSQL Database:"
    puts "  Database  : #{production_db}"
    puts "  Socket    : #{mysql_socket}"
    puts "  User      : #{mysql_user}"
    puts "  Password  : #{mysql_password}"
    puts lines
    if using_ultrasphinx?
      puts "Ultrasphinx"
      puts "  Use Delta : #{sphinx_use_delta}"
      puts "  Path      : #{sphinx_db_path}"
      puts "  Memory    : #{sphinx_mem_limit}"
      puts "  Port      : #{sphinx_server_port}"
      puts "  Min Word  : #{sphinx_min_word_len}"
    end
  end
end