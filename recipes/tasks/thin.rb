Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :thin do
  
    desc "Start thin servers"
    task :start do
      run "thin start -C #{app_server_conf}"
    end
  
    desc "Stop thin servers"
    task :stop do
      run "thin stop -C #{app_server_conf}"
    end
  
    desc "Restart thin servers"
    task :restart do
      run "thin restart -C #{app_server_conf}"
    end
  end
  
end