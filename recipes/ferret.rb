
namespace :ferret do
  
  desc "Stop Ferret Server"
  task :stop do
    inform "Stopping push_server"
    begin
      run "cd #{current_path} && ./script/ferret_server stop"
    rescue
      puts "ferret_server doesn't appear to be running, continue"
    end
  end
  
  desc "Start Ferret Server"
  task :start do
    inform "Starting Ferret Server"
    begin
      run "cd #{current_path} && ./script/ferret_server start"
    rescue
      puts "For some reason ferret_server could not be started"
    end
  end
  
  desc "Restart Ferret Server"
  task :restart do
    inform "Restarting Ferret Server"
    begin
      run "cd #{current_path} && ./script/ferret_server restart"
    rescue
      puts "For some reason ferret_server could not be restarted"
    end
  end

end
