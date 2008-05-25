require "erb"

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
# Staging
set(:staging_server, "10.10.10.10")
set(:staging_deploy_method, "mongrel")
set(:staging_mongrel_port, "8001") 
#birthingfromwithin.com 8000
#dietdocshop.com 8001
#ecounseling.com 8011
#thedietdoc.com 8031
#neighborhood360.com 8061
#ruberion.com 8071 
set(:staging_mongrel_servers, 1)
set(:staging_domains, ["staging.app.com"])
# Production
set(:production_server, "10.10.10.10")
set(:production_deploy_method, "mongrel")
set(:production_mongrel_port, "8001") # we usually jump in groups of 10 starting at 8001
set(:production_mongrel_servers, 1)
set(:production_domains, ["www.app.com", "app.com"])
# Common
set(:application, "app.com")
set(:repository, "git@github.com:xxx/xxx.git")
# Enable Extensions MOST LIKELY TO CHANGE
# Uncomment to change
#set(:enable_ultrasphinx?, true) # default false
#set(:enable_memcached?, true) # default false
#set(:enable_ferret?, true) # default false
#set(:enable_push_server?, true) # default false
#set(:enable_juggernaut?, true) # default false

# "cap deploy staging=true" will deploy to Staging Server
if ENV["staging"]
  set(:webserver1, staging_server)
  # If you want to use Mongrel. 
  # Available options: mongrel, mod_rails
  set(:deploy_method, staging_deploy_method)
  set(:mongrel_port, staging_mongrel_port) # we usually jump in groups of 10 starting at 8001
  set(:mongrel_servers, staging_mongrel_servers)
  # Domain Names for vhosts
  set(:domain_names, staging_domains)
end

# "cap deploy production=true" will deploy to Production Server
if ENV["production"]
  set(:webserver1, production_server)
  # If you want to use mod_rails. 
  # Available options: mongrel, mod_rails
  set(:deploy_method, production_deploy_method)
  set(:mongrel_port, production_mongrel_port) # we usually jump in groups of 10 starting at 8001
  set(:mongrel_servers, production_mongrel_servers)
  # Domain Names for vhosts
  set(:domain_names, production_domains)
end

# Please set where to deploy to
# Default value is to go to /var/www/apps/<application>/
set(:deploy_to, "/var/www/apps/#{application}")

### 
role(:web, webserver1)
role(:app, webserver1)
role(:db,  webserver1, :primary => true)

### GitHub
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
