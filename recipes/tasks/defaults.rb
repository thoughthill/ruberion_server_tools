Capistrano::Configuration.instance(:must_exist).load do
  
  # Defatuls rails_env to production
  _cset(:rails_env) {"production"}

  # Domain names to add to vhost files
  _cset(:vhost_domain_names) { ["localhost"] }

  # SSH user to login in the server
  _cset(:user) {"root"}

  # Use sudo if you need to run privileged tasks
  _cset(:use_sudo) {false}

  # Deploy Methods: mongrel, mod_rails, *dispacht_fcgi*, *thin*, *ebb*
  # *soon I will add those*
  _cset(:deploy_method) {"mongrel"}

  # don't do a fresh checkout, just svn update
  _cset(:deploy_via) {:remote_cache}

  # Add /usr/local/sbin to find Sphinx Binaries
  default_environment["PATH"] = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
  default_run_options[:pty] = true
  _cset(:shell) { "/bin/bash" }
  _cset(:default_shell) { "/bin/bash" }
  
  # ASSETS and symlinks 
  _cset(:public_assets) { abort "Please specify assets, set :public_assets, %w(foo bar)" }
  _cset(:tmp_assets) { %w(sessions cache pids attachment_fu) }
  _cset(:config_assets) { %w(database.yml) }
  _cset(:chmod755) { %w(script) }
  
  # MOD_RAILS
  _cset(:rails_max_pool_size) {1}
  _cset(:rails_pool_idle_time) {3600}
    
  # MONGREL
  _cset(:mongrel_port) {8001}
  _cset(:mongrel_servers) {1}
  _cset(:mongrel_pid) {"#{deploy_to}/#{shared_dir}/pids/mongrel.pid"}
  _cset(:mongrel_conf) {"#{deploy_to}/#{shared_dir}/config/mongrel_cluster.yml"}
  
  # Default sphinx variables
  _cset(:sphinx_use_delta) {false}
  _cset(:sphinx_db_path) {"/opt/local/var/db/sphinx/"}
  _cset(:sphinx_mem_limit) {"128M"}
  _cset(:sphinx_delta_time) {14400}
  _cset(:sphinx_server_port) {3312}
  _cset(:sphinx_min_word_len) {3}
  
  # Backup
  _cset(:backup_path) { "#{shared_path}/backups" }
  _cset(:skip_backup_tables, ['sessions'])
  
  # Enable Extensions
  _cset(:enable_memcached?) {false}
  _cset(:enable_ultrasphinx?) {false}
  _cset(:enable_memcached?) {false}
  _cset(:enable_ferret?) {false}
  _cset(:enable_push_server?) {false}
  _cset(:enable_juggernaut?) {false}
  
  # Database #
  _cset(:development_db) {"#{application.gsub('.', '_')}_development"}
  _cset(:production_db) {"#{application.gsub('.', '_')}_production"}
  _cset(:test_db) {"#{application.gsub('.', '_')}_test"}
  # default socket for Gentoo Linux
  _cset(:mysql_socket) {"/var/run/mysqld/mysqld.sock"}
  _cset(:mysql_user) {"root"}
  _cset(:mysql_password) {""}
  
end