require 'contracts'

module Minesweeper

  # This class represents a minesweeper game

  class Game
    include Contracts::Core
    C = Contracts
    
    Contract C::Pos, C::Pos, C::Pos => C::Any
    def initialize(width, height, num_mines)
      @board = Board.new(width, height, num_mines)
      @playing = true
    end
    
    def still_playing?
      @playing
    end
    
    # Open the cell located at (row, col) position. A play is deemed valid if the cell
    # was closed and unflagged before it happens.
    #
    # @param row a non-negative integer
    # @param col a non-negative integer
    # @return a boolean to indicate if the move was valid
    Contract C::Nat, C::Nat => C::Bool
    def play(row, col)
      return false if not @playing
      is_valid = @board.expand(row,col)
      @playing = (not (@board.exploded? or (@board.closed_cells_without_bomb == 0)))
      is_valid
    end
    
    # Adds/removes a flag to/from a closed cell at row and col position on the
    # board.
    #
    # @param row a non-negative integer
    # @param col a non-negative integer
    # @return a boolean to inform if the flag placement was valid
    Contract C::Nat, C::Nat => C::Bool
    def flag(row, col)
      return false if not @playing
      @board.toggle_flag(row, col)
    end
    
    #
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