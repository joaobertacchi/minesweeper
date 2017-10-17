require "minesweeper/version"

module Minesweeper
  class CellPrinter
    def initialize(cell_format=
      {
        unknown_cell: '.',
        clear_cell: ' ',
        bomb: '#',
        flag: 'F'
      })
      @format=cell_format
    end

    def print(cell)
      return @format[:flag] if cell.flag?
      return @format[:unknown_cell] if not cell.open?
      return @format[:bomb] if cell.bomb?
      return cell.neighbor_bombs.to_s if cell.neighbor_bombs > 0
      return @format[:clear_cell]
    end
  end

  class Cell
    attr_accessor :neighbor_bombs
    def initialize(bomb, flag=false, open=false, neighbor_bombs=nil)
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

  class Printer
    def print
      raise 'not implemented'
    end
  end

  class SimplePrinter < Printer
    def initialize
    end


  end

  class PrettyPrinter < Printer
    # def initialize
    # end
  end
end
