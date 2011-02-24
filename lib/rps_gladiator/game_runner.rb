require 'xmpp4r-simple'
require 'yaml'

module RPSGladiator
  class GameRunner
    include XMLTools
    
    attr_accessor :client
    
    def initialize
      @config = YAML::load(File.read('config/settings.yml'))
      connect
      run_game
    end

    def connect
      @client = Jabber::Simple.new(@config['bot']['jid'], @config['bot']['password'])
    end

    def run_game
      running = true
      register
      while running
        @client.received_messages do |msg|
          dispatcher(Nokogiri::XML(msg.body).root)
        end
        sleep 1
      end
    end

    def dispatcher(xml_doc)
      case xml_doc.name
      when 'RegistrationComplete'
        puts "Registered!"
      when 'TournamentStarted'
        puts 'Tourney Started!'
      when 'GameStart'
        create_game(xml_doc)
        puts "Started Game #{@game.id}"
      when 'TurnStart'
        move = @game.get_move
        @client.deliver(@config['server']['name'], move)
      when 'TurnResult'
        puts xml_doc.to_xml
      when 'GameOver'
        puts 'Game Over'
        running = false
      end
    end

    def create_game(xml_node)
      game_options = {
        :id => xpath_query(xml_node, "GameId"),
        :max_moves => xpath_query(xml_node, "MaxMoves"),
        :bubbles => xpath_query(xml_node, "AllowBubbles"),
        :dynamite_count => xpath_query(xml_node, "DynamiteCount")
      }
      @game = Game.new(game_options)
    end

    def register
      @client.deliver(@config['server']['name'], registration_xml)
    end

    def registration_xml
      Nokogiri::XML::Builder.new do
        Register(XMLTools::GAME_NS)
      end.doc.children.to_xml
    end
  end
end


RPSGladiator::GameRunner.new
