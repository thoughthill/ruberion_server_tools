#############################################################
#       Passenger
#############################################################

Capistrano::Configuration.instance(:must_exist).load do
    
  # if deploy_method is set to mod_rails
  # set(:deploy_method, "mod_rails")
  if deploy_method == "mod_rails"
  
    namespace :passenger do
     desc "Restart Application (mod_rails)"
     task :restart do
       run "touch #{current_path}/tmp/restart.txt"
     end
    end
  
    namespace :deploy do
     desc "Restart Passenger (mod_rails)"
     task :restart do
       "passenger:restart"
       run "ln -nfs #{shared_path}/tmp/attachment_fu/ #{current_path}/tmp/"
       run "chmod -R 755 #{current_path}/tmp"
      end
    end
  
  end
  
end