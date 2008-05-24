set(require "erb"

if (ENV["staging"].nil? and ENV["production"].nil?)
  puts "._______________________________________________________________."
  puts "| WARNING, you didn't specify a Target.                         |"
  puts "| 'cap deploy staging=true' will deploy to Staging Server       |"
  puts "| 'cap deploy production=true' will deploy to Production Server |"
  puts "| or to make it fixed for the session 'export staging=true'     |"
  puts "|   alternatively you can run 'cap env:list' to see the setup   |"
  puts "|_______________________________________________________________|"
  abort
end

# "cap deploy staging=true" will deploy to Staging Server
if ENV["staging"]
  set(:webserver1, "10.10.10.10")
  # If you want to use Mongrel. 
  # Available options: mongrel, mod_rails
  set(:deploy_method, "mongrel")
  set(:mongrel_port, "8001") # we usually jump in groups of 10 starting at 8001
  set(:mongrel_servers, 1)
  # Domain Names for vhosts
  set(:domain_names, ["staging.app.com"])
end

# "cap deploy production=true" will deploy to Production Server
if ENV["production"]
  set(:webserver1, "10.11.11.11")
  # If you want to use mod_rails. 
  # Available options: mongrel, mod_rails
  set(:deploy_method, "mod_rails")
  # Domain Names for vhosts
  set(:domain_names, ["www.app.com", "app.com"])
end

# Please set the name of the domain/application here
set(:application, "app.com")

# Please set where to deploy to
# Default value is to go to /var/www/apps/<application>/
set(:deploy_to, "/var/www/apps/#{application}")

### 
role(:web, webserver1)
role(:app, webserver1)
role(:db,  webserver1, :primary => true)

### GitHub
set(:repository, "git@github.com:xxx/xxx.git")
set(:scm, "git")
set(:scm_passphrase, "" )
set(:git_enable_submodules, true)
set(:deploy_via, :remote_cache)

### ASSETS ###
# links inside public/ folder,
set(:public_assets, %w(uploads) )
# links inside tmp/ folder,
set(:tmp_assets, %w(sessions cache pids) )
# links inside config/ folder,
set(:config_assets, %w(database.yml) )

### These are all defaulted in ruberion_server_tools/recipes/defaults.rb

# Enable Extensions MOST LIKELY TO CHANGE
#set(:enable_memcached?,false)
#set(:enable_ultrasphinx?,false)
#set(:enable_memcached?, false)
#set(:enable_ferret?, false)
#set(:enable_push_server?, false)
#set(:enable_juggernaut?, false)

### Servers
# Sets the environment in rails
# Defaults rails_env to production
#set(:rails_env, "production")

# Domain names to add to vhost files
#set(:vhost_domain_names, ["localhost"])

# SSH user to login in the server
#set(:user, "root")

# Use sudo if you need to run privileged tasks
#set(:use_sudo, false)

# MOD_RAILS
#set(:rails_max_pool_size, 1)
#set(:rails_pool_idle_time, 3600)
  
# MONGREL
#set(:mongrel_pid, "#{deploy_to}/#{shared_dir}/pids/mongrel.pid")
#set(:mongrel_conf, "#{deploy_to}/#{shared_dir}/config/mongrel_cluster.yml")

# Default sphinx variables
#set(:sphinx_use_delta, false)
#set(:sphinx_db_path, "#{shared_path}/index/sphinx/")
#set(:sphinx_mem_limit, "128M")
#set(:sphinx_delta_time, 14400)
#set(:sphinx_server_port, 3312)
#set(:sphinx_min_word_len, 3)

# Backup
#set(:backup_path,  "#{shared_path}/backups" }
#set(:skip_backup_tables, ['sessions'])

## Default values
# Database #
#set(:development_db, "#{application.gsub('.', '_')}_development")
#set(:production_db, "#{application.gsub('.', '_')}_production")
#set(:test_db, "#{application.gsub('.', '_')}_test")

# default socket for Gentoo Linux
#set(:mysql_socket, "/var/run/mysqld/mysqld.sock")
#set(:mysql_user, "root")
#set(:mysql_password, "")
