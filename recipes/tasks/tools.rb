Capistrano::Configuration.instance(:must_exist).load do
  namespace :tools do
  
    namespace :gems do
    
      task :default do
        puts "Tasks to adminster Ruby Gems on a remote server: \n \n
          cap tools:gems:list \n
          cap tools:gems:update \n
          cap tools:gems:install \n
          cap tools:gems:remove \n"
      end
    
      desc "List gems on remote server"
      task :list do
        stream "gem list"
      end
    
      desc "Update gems on remote server"
      task :update do
        run "gem update"
      end
    
      desc "Install a gem on the remote server"
      task :install do
        # TODO Figure out how to use Highline with this
        puts "Enter the name of the gem you'd like to install:"
        gem_name = $stdin.gets.chomp
        logger.info "trying to install #{gem_name}"
        run "gem install #{gem_name}"
      end
    
      desc "Uninstall a gem from the remote server"
      task :remove do
        puts "Enter the name of the gem you'd like to remove:"
        gem_name = $stdin.gets.chomp
        logger.info "trying to remove #{gem_name}"
        gem "gem install #{gem_name}"
      end
    
    end
  
  end
  
end