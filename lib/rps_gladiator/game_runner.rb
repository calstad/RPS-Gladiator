require 'nokogiri'
require 'xmpp4r-simple'
require 'yaml'

module RPSGladiator
  class GameRunner
    def initialize
      @config = YAML::load(File.read('config/settings.yml'))
      connect
      register_setup
    end

    def connect
      @client = Jabber::Simple.new(@config['bot']['jid'], @config['bot']['password'])
    end

    def register_setup
      register
      puts 'Registered!'
      setup_tourny
      puts 'Got tourney info!'
      setup_game
      puts "Game setup!"
      run_game
    end

    def setup_tourny
      running=true
      while running
        @client.received_messages do |msg|
          if Nokogiri::XML(msg.body).root.name == 
            running = false
          end
        end
        sleep 1
      end
    end

    def setup_game
      running = true
      while running
        @client.received_messages do |msg|
          puts msg.body
          doc = Nokogiri::XML(msg.body)
          if doc.root.name == 'GameStart'
            game_optiions = {
              :id => xpath_query(doc.root, "GameId"),
              :max_moves => xpath_query(doc.root, "MaxMoves"),
              :bubbles => xpath_query(doc.root, "AllowBubbles"),
              :dynamite_coount => xpath_query(doc.root, "DynamiteCount")
            }
            @game = Game.new(game_options)
            running = false
          end
        end
        sleep 1
      end
    end

    def run_game
      running = true
      while running
        @client.received_messages do |msg|
          doc = Nokogiri::XML(msg.body)
          case doc.root.name
          when 'RegistrationComplete'
            puts "Registered!"
          when 'TournamentStarted'
            'Tourney Started!'
          when 'GameStart'
            game_optiions = {
              :id => xpath_query(doc.root, "GameId"),
              :max_moves => xpath_query(doc.root, "MaxMoves"),
              :bubbles => xpath_query(doc.root, "AllowBubbles"),
              :dynamite_coount => xpath_query(doc.root, "DynamiteCount")
            }
            @game = Game.new(game_options)
          when 'TurnStart'
            move = @game.get_move
            @client.deliver(@config[:server][:name], move)
          when 'TurnResult'
            puts doc.root.to_xml
          when 'GameOver'
            running = false
          end
        end
        sleep 1
      end
    end

    def register
      @client.deliver(@config['server']['name'], registration_xml)
    end
    
    def registration_xml
      Nokogiri::XML::Builder.new do
        Register("xmlns"=>"http://charlestonaltnet.org/xml/RPS", "xmlns:i"=>"http://www.w3.org/2001/XMLSchema-instance")
      end.doc.children.to_xml
    end

    def xpath_query(node, query)
      node.xpath("//game:#{query}", "game" => "http://charlestonaltnet.org/xml/RPS").text
    end
  end

  class Game
    MOVES = ['rock', 'paper', 'scissors']

    def initialize(opts)
      @id = opts[:id]
      @max_moves = opts[:moves]
      @dynamite_count = opts[:dynamite_count]
      @bubbles = opts[:bubbles] == 'true'
    end

    def get_move
      move = MOVES[rand(3)]
      xml = Nokogiri::XML::Builder.new do
        PlayerMove("xmlns"=>"http://charlestonaltnet.org/xml/RPS", "xmlns:i"=>"http://www.w3.org/2001/XMLSchema-instance") {
          GameId id
          Move move
        }.doc.children.to_xml
      end
    end
  end
end

RPSGladiator::GameRunner.new
