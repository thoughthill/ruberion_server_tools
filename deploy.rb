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

### Servers
set(:application, "app.com")
set(:deploy_to, "/var/www/apps/#{application}")

### 
role :web, webserver1
role :app, webserver1
role :db,  webserver1, :primary => true

### GitHub
set(:repository, "git@github.com:xxx/xxx.git")
set(:scm, "git")
set(:scm_passphrase, "" )
set(:deploy_via, :remote_cache)
set(:git_enable_submodules, 1)


### ASSETS ###
# links inside public/ folder,
set(:public_assets, %w(uploads) )
# links inside tmp/ folder,
set(:tmp_assets, %w(sessions cache pids) )
# links inside config/ folder,
set(:config_assets, %w(database.yml) )