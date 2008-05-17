
load 'config/deploy'

# Add this path to ruby load path
$:.unshift File.dirname(__FILE__)

require "tasks/configuration"
require "tasks/defaults"
require "tasks/assets"
require "tasks/create_config"
require "tasks/ferret"
require "tasks/ultrasphinx"
require "tasks/push_server"
require "tasks/mongrel"
require "tasks/mod_rails"
require "tasks/thin"
require "tasks/tools"
require "tasks/show_env"

