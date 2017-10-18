module Minesweeper
  class Cell
    attr_accessor :neighbor_bombs
    def initialize(bomb, flag=false, open=false, neighbor_bombs=0)
      @open = open
      @flag = flag
      @bomb = bomb
      @neighbor_bombs = neighbor_bombs
    end
    
    def bomb?
      @bomb
    end
    
    def open?
      @open
    end
    
    def flag?
      @flag
    end
    
    def play
      if ((not @open) and (not @flag)) then
        @open = true
      else
        false
      end
    end
    
    def toggle_flag
      if not @open then
        @flag = (not @flag)
        return true
      else
        return false
      end
    end

    def state(xray=false)
      return :flag if ((self.flag?) and (not xray))
      return :unknown_cell if not self.open? and not xray
      return :bomb if self.bomb?
      return self.neighbor_bombs if self.neighbor_bombs > 0
      return :clear_cell
    end
  end
end