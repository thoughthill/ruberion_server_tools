require "erb"

### Servers
role :web, webserver1
role :app, webserver1
role :db,  webserver1, :primary => true

set(:application, "www.app.com")
set(:deploy_to, "/var/www/apps/#{application}")
set(:webserver1, "67.76.67.76")
set(:rails_env, "production")
set(:domain_names, ["www.app.com", "app.com"])

# If you want to use Mongrel. 
# Available options: mongrel, mod_rails
set(:deploy_method, "mongrel")
set(:mongrel_port, "8001") 
set(:mongrel_servers, 1)

### GitHub
default_run_options[:pty] = true
set(:repository, "git@github.com:xxx/xxx.git")
set(:scm, "git")
set(:scm_passphrase, "" )
set(:deploy_via, :remote_cache)

### ASSETS ###
# links inside public/ folder,
set(:public_assets, %w(uploads) )
# links inside tmp/ folder,
set(:tmp_assets, %w(sessions cache pids) )
# links inside config/ folder,
set(:config_assets, %w(database.yml environment.rb) )
