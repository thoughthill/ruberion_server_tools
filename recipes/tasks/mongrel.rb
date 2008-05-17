#############################################################
#       Mongrels
#############################################################

# Deprecated.  The functionality is now in mongrel_cluster for Cap 2

Capistrano::Configuration.instance(:must_exist).load do
  
  if deploy_method == "mongrel"
    # Use mongrel 
    namespace :deploy do
      desc "Restart Mongrel servers"
      task :restart do
        deploy.mongrel.restart
      end
    end
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