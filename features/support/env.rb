require 'rspec/matchers'
require 'yaml'

include RSpec::Matchers

config_file = File.expand_path('../../../.os_accept.yml',__FILE__)
unless File.exists?(config_file)
  puts 'ConfigFile Not Found. Try `./bin/os_accept init` first.'
  exit
end
$os_config = YAML.load_file(config_file)
puts $os_config
