require "nokogiri"

module RPSGladitor
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
