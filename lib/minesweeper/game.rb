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
      
      init_random_board
      set_neighbor_bombs
    end
    
    def still_playing?
      true
    end
    
    def play(x, y)
      @board[x][y].play
    end
    
    def flag(x, y)
      @board[x][y].toggle_flag
    end
    
    def print_board_state
      cell_printer = CellPrinter.new
      (0..(@height-1)).each do |i|
        puts "%s "*@width % @board[i].map{|cell| cell_printer.print(cell, true)}
      end
    end
    
    def board_state(config={xray: false})
      xray = config[:xray] if config.key?(:xray)

      @board.map do |line|
        line.map{|cell| cell.state(xray)}
      end
    end

    def victory?
      false
    end

    def count_bombs
      bombs = 0
      (0..(@height-1)).each do |i|
        (0..(@width-1)).each do |j|
          #puts "#{i}, #{j}"
          bombs += 1 if @board[i][j].bomb?
        end
      end
      bombs
    end

    private
    def init_random_board
      @board = Array.new(height) { Array.new(width) }

      num_non_mines = @width*@height - @num_mines
      cells = (Array.new(@num_mines){Cell.new(true)} + Array.new(num_non_mines){Cell.new(false)}).shuffle

      index = 0
      cells.each do |cell|
        i = index / @width
        j = index % @width

        @board[i][j] = cell
        #puts "#{i}, #{j} => #{cell.bomb?}"

        index += 1
      end
    end

    def set_neighbor_bombs
      (0..(@height-1)).each do |i|
        (0..(@width-1)).each do |j|
          increment_neighbors(i, j) if @board[i][j].bomb?
        end
      end
    end

    def increment_neighbors(x, y)
      ((x-1)..(x+1)).each do |i|
        if i >=0 and i < @height then
          ((y-1)..(y+1)).each do |j|
            if j >= 0 and j < @width then
              @board[i][j].neighbor_bombs += 1 if i != x or j != y
            end
          end
        end
      end
    end
    
  end
end