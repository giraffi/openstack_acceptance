require 'rspec/matchers'
require 'fog'
require 'yaml'

include RSpec::Matchers
include RSpec::Expectations

config_file = File.expand_path('../../../.os_accept.yml',__FILE__)
unless File.exists?(config_file)
  puts 'ConfigFile Not Found. Try `./bin/os_accept init` first.'
  exit
end
$os_config = YAML.load_file(config_file)
