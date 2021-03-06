require 'contracts'

module Minesweeper
  # Objects of this class store the state of cells from minesweeper board.
  class Cell
    include Contracts::Core
    include Contracts::Builtin
    C = Contracts

    attr_accessor :neighbor_bombs

    # @param bomb cell has a bomb
    # @param flag cell is flagged
    # @param open cell is open
    # @param neighbor_bombs amount of neighbor cells with mines
    Contract C::Bool, C::Bool, C::Bool, C::Nat => C::Any
    def initialize(bomb, flag = false, open = false, neighbor_bombs = 0)
      @open = open
      @flag = flag
      @bomb = bomb
      @neighbor_bombs = neighbor_bombs
    end

    # @return true if the cell has a bomb
    Contract C::None => C::Bool
    def bomb?
      @bomb
    end

    # @return true if the cell is open
    Contract C::None => C::Bool
    def open?
      @open
    end

    # @return true if the cell is flagged
    Contract C::None => C::Bool
    def flag?
      @flag
    end

    # Tries to open the cell. To have success the cell must be previously closed and not be flagged.
    # @return true if the cell could be open.
    Contract C::None => C::Bool
    def play
      if !@open && !@flag
        @open = true
      else
        false
      end
    end

    # Toggles the flag status. An open cell cannot be flagged.
    # @return true if flag status could be toggled. False otherwise.
    Contract C::None => C::Bool
    def toggle_flag
      if !@open
        @flag = !@flag
        true
      else
        false
      end
    end

    # @param xray if it is true, even a closed cell reveals if it has a bomb
    # @return the state of the cell. Valid states: :bomb, :flag, :unknown_cell, :clear_cell, <number>
    Contract C::Bool => C::Or[Symbol, C::Pos]
    def state(xray = false)
      return :bomb if bomb? && xray
      return :flag if flag?
      return :unknown_cell unless open?
      return :bomb if bomb?
      return neighbor_bombs if neighbor_bombs > 0
      :clear_cell
    end
  end
end
