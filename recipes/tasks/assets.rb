Capistrano::Configuration.instance(:must_exist).load do

  after "deploy:setup", "assets:setup"
  after "deploy:symlink", "assets:setup", "assets:symlink", "assets:plugin_symlinks", "assets:set_permissions"

  namespace :assets do
    
    desc "This will create the appropriate asset directories"
    task :setup, :role => :app do
      run "cd #{shared_path}; umask 02 && mkdir -p config"
      unless public_assets.empty?
        run "cd #{shared_path}; umask 02 && mkdir -p #{public_assets.join(' ')}"
      end
      unless tmp_assets.empty?
        run "cd #{shared_path}; umask 02 && mkdir -p #{tmp_assets.join(' ')}"
      end
      if enable_ferret?
        run "mkdir -p #{shared_path}/index"
      end
      if enable_ultrasphinx?
        run "mkdir -p #{shared_path}/config/ultrasphinx"
        run "mkdir -p #{sphinx_db_path}/#{rails_env}"
      end  
    end
    
    desc "This will create the symlinks for assets"
    task :symlink, :role => :app do
      unless config_assets.empty?
        fetch(:config_assets).each do |file|
          run "ln -nfs #{shared_path}/config/#{file} #{current_path}/config/#{file}" 
        end
      end
      
      unless public_assets.empty?
        fetch(:public_assets).each do |dir|
          run "rm -rf  #{release_path}/public/#{dir}"
          run "ln -nfs #{shared_path}/#{dir} #{current_path}/public/"
        end
      end
      
      unless tmp_assets.empty?
        fetch(:tmp_assets).each do |dir|
          run "rm -rf  #{current_path}/tmp/#{dir}"
          run "ln -nfs #{shared_path}/#{dir} #{current_path}/tmp/"
        end
      end
    end
    
    desc "Create the symlinks for the plugins config files"
    task :plugin_symlinks, :role => :app do
      run "ln -nfs #{shared_path}/config/ultrasphinx #{current_path}/config/ultrasphinx" if enable_ultrasphinx?
      run "ln -nfs #{shared_path}/config/memcached.yml #{current_path}/config/memcached.yml" if enable_memcached?
      run "ln -nfs #{shared_path}/config/ferret_server.yml #{current_path}/config/ferret_server.yml" if enable_ferret?
      run "ln -nfs #{shared_path}/config/juggernaut_config.yml #{current_path}/config/juggernaut_config.yml" if enable_juggernaut?
    end
  
    desc "Set the proper permissions for directories and files on the script folder"
    task :set_permissions do
      run(chmod755.collect do |item|
        "chmod -R 755 #{current_path}/#{item}*"
      end.join(" && "))
    end
  
  end
  
end
