require 'bundler/setup'
Bundler.setup

require 'tres_delta'

config_file = File.expand_path(File.join(File.dirname(__FILE__), '../config/three_delta.yml'))

unless File.exists?(config_file)
  puts "You must have a config/three_delta.yml file. See config/three_delta.sample.yml for proper format"
  exit 1
end

require 'yaml'

TresDelta::Config.config = YAML.load_file(config_file)

RSpec.configure do |config|
  # TODO: CONFIGURE SOME RSPEC
end
