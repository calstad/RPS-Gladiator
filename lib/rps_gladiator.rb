directory = File.expand_path(File.dirname(__FILE__))
required_files = ['rps_gladiator/xml_tools', 'rps_gladiator/game', 'rps_gladiator/game_runner']

required_files.each do |file|
  require (directory + '/' + file)
end

