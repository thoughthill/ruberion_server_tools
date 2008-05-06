# these Tasks will take care of a Push Server, 

namespace :push_server do
  
  desc "Stop the Push Server"
  task :stop do
    inform "Stopping push_server"
    begin
      run "cd #{current_path} && ./script/push_server stop"
    rescue
      puts "For some reason, push_server could not be stopped"
    end
  end
  
  desc "Start the Push Server"
  task :start do
    inform "Starting push_server"
    begin
      run "cd #{current_path} && ./script/push_server start"
    rescue
      puts "For some reason, push_server could not be started"
    end
  end
  
  desc "Restart the Push Server"
  task :restart do
    inform "Restarting push_server"
    stop
    sleep 2
    start
  end

end
