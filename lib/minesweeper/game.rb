module Minesweeper

  ##
  # This class represents a minesweeper game

  class Game
    attr_accessor :width, :height, :num_mines
    
    def initialize(width, height, num_mines)
      @board = Board.new(width, height, num_mines)
      @playing = true
    end
    
    def still_playing?
      @playing
    end
    
    def play(row, col)
      return false if not @playing
      is_valid = @board.expand(row,col)
      @playing = (not (@board.exploded? or (@board.closed_cells_without_bomb == 0)))
      is_valid
    end
    
    ##
    # Adds a flag to an unclicked cell or removes an existent flag.
    # Returns a boolean to inform the validity of the play.

    def flag(x, y)
      return false if not @playing
      @board.toggle_flag(x,y)
    end
    
    ##
    # Returns the current board representation as a height X width matrix.
    # Each matrix element may have the following states:
    # - :unknown_cell - closed cell
    # - :clear_cell - open cell with no neighbor bombs
    # - :bomb - open cell with a bomb
    # - :flag - closed cell with a flagged
    # - n - n is a integer from 1 to 8. Indicates an open cell with n neighbor bombs
    #
    # config param is an optional hash that follows {xray: bool} format. This param is
    # ignored unless the game is over. In that case, closed cells with bombs will be
    # uncovered and returned with :bomb state.

    def board_state(config={xray: false})
      config = {xray: false} if @playing
      @board.board_state(config)
    end

    ##
    # Returns true if the game is over and the player won. Return false otherwise.

    def victory?
      ((not @playing) and (not @board.exploded?))
    end
    
  end
end