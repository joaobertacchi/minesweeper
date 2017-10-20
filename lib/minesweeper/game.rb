module Minesweeper

  ##
  # This class represents a minesweeper game

  class Game
    attr_accessor :width, :height, :num_mines
    
    def initialize(width, height, num_mines)
      @board = Board.new(width, height, num_mines)
      @game_finished = false
    end
    
    def still_playing?
      not @game_finished
    end
    
    def play(row, col)
      return @board.expand(row,col)
      # valid_play = false
      # if @playing then
      #   valid_play = @board[row][col].play
      #   @game_finished = true if valid_play and @board[row][col].bomb?
      #   expand([@board[row][col]])
      # end
      # valid_play
    end
    
    ##
    # Adds a flag to an unclicked cell or removes an existent flag.
    # Returns a boolean to inform the validity of the play.

    def flag(x, y)
      @board.toggle_flag(x,y)
    end
    
    def board_state(config={xray: false})
      @board.board_state(config)
    end

    def victory?
      false
    end
    
  end
end