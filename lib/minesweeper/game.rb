require 'contracts'

# Minesweeper module contains all the classes you need to create a minesweeper game
module Minesweeper
  # This class represents a minesweeper game
  class Game
    include Contracts::Core
    include Contracts::Builtin
    C = Contracts

    Contract C::Pos, C::Pos, C::Nat => C::Any
    def initialize(width, height, num_mines)
      @board = Board.new(width, height, num_mines)
      @playing = true
    end

    # Returns true if the game is not finished. Return false otherwise.
    # The game finishes when a bomb is clicked or all non-bomb cells are uncovered.
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
      return false unless @playing
      is_valid = @board.expand(row, col)
      @playing = !(@board.exploded? || (@board.closed_cells_without_bomb == 0))
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
      return false unless @playing
      @board.toggle_flag(row, col)
    end

    # Returns the current board representation as a height X width matrix.
    # Each matrix element may have the following states:
    # - :unknown_cell - closed cell
    # - :clear_cell - open cell with no neighbor bombs
    # - :bomb - open cell with a bomb
    # - :flag - closed cell with a flagged
    # - <number> - is a integer from 1 to 8. Indicates an open cell with <number> neighbor bombs
    #
    # Param config is ignored unless the game is over. In this case, closed cells
    # with bombs (with or without flag) return :bomb state.
    # @param config optional hash to enable xray feature. Works only if the game is finished
    # @return the current board representation as a height X width matrix.
    Contract C::Maybe[C::KeywordArgs[xray: C::Bool]] => C::ArrayOf[C::ArrayOf[Or[Symbol, C::Pos]]]
    def board_state(config = { xray: false })
      config = { xray: false } if @playing
      @board.board_state(config)
    end

    # @return true if the game is over and the player won. Return false otherwise.
    def victory?
      (!@playing && !@board.exploded?)
    end

    # @private
    attr_writer :board
  end
end
