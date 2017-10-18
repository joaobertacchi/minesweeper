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
  end
end