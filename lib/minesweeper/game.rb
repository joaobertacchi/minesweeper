module Minesweeper
  class Game
    attr_accessor :width, :height, :num_mines
    
    def initialize(width, height, num_mines)
      raise "num_mines should be <= width*height" if num_mines > width*height
      # raise "width should be an Integer" if not width.is_a?(Fixnum)
      # raise "height should be an Integer" if not height.is_a?(Fixnum)
      # raise "num_mines should be an Integer" if not num_mines.is_a?(Fixnum)
      @width = width
      @height = height
      @num_mines = num_mines
      
      @board = Array.new(height) { Array.new(width, Cell.new(false)) }
    end
    
    def still_playing?
      true
    end
    
    def play(x, y)
      true
    end
    
    def flag(x, y)
      true
    end
    
    def board_state
    end
    
    def victory?
      false
    end
    
  end
end