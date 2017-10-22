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
    def initialize(bomb, flag=false, open=false, neighbor_bombs=0)
      @open = open
      @flag = flag
      @bomb = bomb
      @neighbor_bombs = neighbor_bombs
    end
    
    # Cell has a bomb
    Contract C::None => C::Bool
    def bomb?
      @bomb
    end
    
    # Cell is open
    Contract C::None => C::Bool
    def open?
      @open
    end
    
    # Cell is flagged
    Contract C::None => C::Bool
    def flag?
      @flag
    end
    
    # Tries to open the cell. To have success the cell must be previously closed and not be flagged.
    # @return true if the cell could be open.
    Contract C::None => C::Bool
    def play
      if ((not @open) and (not @flag)) then
        @open = true
      else
        false
      end
    end
    
    # Toggles the flag status. An open cell cannot be flagged.
    # @return true if flag status could be toggled. False otherwise.
    Contract C::None => C::Bool
    def toggle_flag
      if not @open then
        @flag = (not @flag)
        return true
      else
        return false
      end
    end

    def state(xray=false)
      return :bomb if self.bomb? and xray
      return :flag if self.flag?
      return :unknown_cell if not self.open?
      return :bomb if self.bomb?
      return self.neighbor_bombs if self.neighbor_bombs > 0
      return :clear_cell
    end
  end
end