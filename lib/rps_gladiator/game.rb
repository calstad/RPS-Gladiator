module RPSGladiator
  class Game
    MOVES = ['rock', 'paper', 'scissors']
    attr_reader :id

    def initialize(opts)
      @id = opts[:id]
      @max_moves = opts[:max_moves]
      @dynamite_count = opts[:dynamite_count]
      @bubbles = opts[:bubbles] == 'true'
    end

    def get_move
      move = MOVES[rand(3)]
    end
  end
end
