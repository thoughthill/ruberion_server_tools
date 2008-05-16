class Capistrano::Configuration

  ##
  # Print an informative message with asterisks.
  def inform(message)
    puts "#{'*' * (message.length + 4)}"
    puts "* #{message} *"
    puts "#{'*' * (message.length + 4)}"
  end

  ##
  # Read a file and evaluate it as an ERB template.
  # Path is relative to this file's directory.

  def render_erb_template(filename)
    template = File.read(filename)
    result   = ERB.new(template).result(binding)
  end

  ##
  # Run a command and return the result as a string.
  #
  # TODO May not work properly on multiple servers.

  def run_and_return(cmd)
    output = []
    run cmd do |ch, st, data|
      output << data
    end
    return output.to_s
  end
  
  def ultrasphinx_configured?
    result = run_and_return("ls -al #{shared_path}/config/ultrasphinx/")
    if result.match("default.base")
      return true
    else
      return false
    end
  end
    
  def _cset(name, *args, &block)
    unless exists?(name)
      set(name, *args, &block)
    end
  end

end