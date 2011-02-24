require 'xmpp4r-simple'
require 'yaml'

module RPSGladiator
  class GameRunner
    include XMLTools
    
    attr_accessor :client
    
    def initialize
      @config = YAML::load(File.read('config/settings.yml'))
      @game_pool = []
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
      when 'TurnStart'
        game_id = xpath_query(xml_doc, "GameId")
        game = @game_pool.detect {|g| g.id == game_id}
        move_data = {:move => game.get_move, :id => game.id}
        move_xml = generate_game_xml('player_move', move_data)
        @client.deliver(@config['server']['name'], move_xml)
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
      @game_pool << Game.new(game_options)
    end

    def register
      @client.deliver(@config['server']['name'], generate_game_xml('registration'))
    end

  end
end


RPSGladiator::GameRunner.new
