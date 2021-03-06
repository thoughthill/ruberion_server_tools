require 'erb'

namespace :setup do
  
  desc "Creates necessary dirs, log, tmp, ..." 
  task :create_required_dirs do
    inform "Creating required dirs"
    system "mkdir -p log"
    system "mkdir -p tmp/pids"
    system "mkdir -p tmp/cache"
    system "mkdir -p tmp/sessions"
  end
  
  desc "create config files for ultrasphinx" 
  task :setup_ultrasphinx do
    # check if the ultrasphinx example folder is in there
    # if it is, create the folder and copy the sample files
    # if it is not there, copy from plugins/ultrasphinx/examples
    check_sphinx_installed
    config_files = Dir.entries("./config/")
    if (sample_dir = config_files.find {|t| t.match(/ultrasphinx\./)})
      inform "Creating and copying config/ultrasphinx.example/* to config/ultrasphinx/"
      system "mkdir -p config/ultrasphinx; cp config/#{sample_dir}/* config/ultrasphinx/"
    else
      # copy from plugins/ultrasphinx/examples/default.base
      system("mkdir config/ultrasphinx; cp vendor/plugins/ultrasphinx/examples/default.base config/ultrasphinx/")
    end
  end
  
  desc "configure ultrasphinx" 
  task :configure_ultrasphinx do
    check_sphinx_installed
    if Dir.entries("./config/").find { |t| t.match(/ultrasphinx/) }
      begin
        inform "Runing ultrasphinx:configure"
        Rake::Task['ultrasphinx:configure'].invoke
      rescue
        inform "Make sure you have Sphinx-0.9.8RC2 Installed."
      end
    end
  end
  
  desc "index ultrasphinx"
  task :index_ultrasphinx do
    check_sphinx_installed
    if Dir.entries("./config/").find { |t| t.match(/ultrasphinx/) }
      begin
        inform "Runing ultrasphinx:index"
        Rake::Task['ultrasphinx:index'].invoke
        puts "Ultrasphinx is set, make sure you run rake ultrasphinx:daemon:start"
      rescue
        inform "Make sure you have Sphinx-0.9.8RC2 Installed."
      end
    end
  end

  
  # Generates the database.yml
  task :create_database_yml do
    check_arguments
    if File.exists?("./config/database.yml")
      inform "config/database.yml already exist. Skiping."
    else
      inform "Im going to generate database.yml for you."
      file = File.open("vendor/plugins/ruberion_server_tools/tasks/database.yml.erb", "r")
      content = file.readlines.join
      database_yml = ERB.new(content, 0, "%<>")
      file.close
      file = File.open("./config/database.yml", "w")
      file.syswrite(database_yml.result)
      puts "database.yml created succesfully..."
    end
  end
  
  desc "Setup mysql databases"
  task :setup_database => :environment do
    envs = ["development", "test"]
    envs.each do |env|
      RAILS_ENV = env
      inform "Setting up #{env} database..."
      begin 
        system "RAILS_ENV=#{env} rake db:drop"
      rescue
        puts "database does not exist"
      end
      system "RAILS_ENV=#{env} rake db:create"
      system "RAILS_ENV=#{env} rake db:schema:load"
      system "RAILS_ENV=#{env} rake spec:db:fixtures:load"
    end
  end
  
  desc "Copy plugin test files to spec folder"
  task :copy_test_files do
    system("vendor/plugins/ruberion_server_tools/spec/*.rb", "./spec/")
  end
  
  
  
  # dont change the order
  desc "Run Setup to get the Application ready to roll."
  task :initialize do
    Rake::Task['setup:create_required_dirs'].invoke
    Rake::Task['setup:create_database_yml'].invoke
    if check_ultrasphinx_plugin
      Rake::Task['setup:setup_ultrasphinx'].invoke
      Rake::Task['setup:configure_ultrasphinx'].invoke
    end
    Rake::Task['setup:setup_database'].invoke
    if check_ultrasphinx_plugin
      #Rake::Task['setup:index_ultrasphinx'].invoke
    end
  end

end

  private

  def inform(text)
    puts "*"*text.size
    puts text
    puts "*"*text.size
  end
  
  def check_arguments
    if ENV["application"]
      @application = ENV["application"]
    else
      show_usage
    end
    
    if ENV["username"]
      @mysql_username = ENV["username"]
    else
      @mysql_username = "root"
    end
    
    if ENV["password"]
      @mysql_password = ENV["password"]
    else
      @mysql_password = ""
    end
    
    if ENV["host"]
      @mysql_host = ENV["host"] 
    else
      @mysql_host = "localhost"
    end
    
  end
  
  
  def show_usage
    puts "USAGE: rake setup:initialize [options]"
    puts "Required fields: application"
    puts "Optional fields: username, password, host."
    puts " application='app_name' \n"+
         " username='root' \n"+
         " password='' \n"+
         " host='localhost'"
    exit
  end
  
  def check_ultrasphinx_plugin
    plugins = Dir.entries("./vendor/plugins/")
     if plugins.find {|t| t.match(/ultrasphinx/)}
       true
     else
       false
     end
  end

  def sphinx_installed(version)
    begin
      if IO.popen("searchd -h").readline.match(version)
        true
      else
        false
      end
    rescue EOFError
      false
    end
  end
  
  def check_sphinx_installed
    @version = "Sphinx 0.9.8-rc2"
    if sphinx_installed(@version)
      true
    else
      inform "Abort: "
      puts "Fatal: #{@version} is not installed on the system, or it was not found in the PATH"
      abort
    end
  end
  