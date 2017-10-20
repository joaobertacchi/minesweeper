module Minesweeper
  
  class Board
    attr_accessor :width, :height, :num_mines

    ##
    # width, height, and num_mines are integers. num_mines must be <= width*height
    # bombs_position is an matrix of height X width dimension. Its elements are
    # 1 to indicate a bomb and 0 to indicate no-bomb.

    def initialize(width, height, num_mines, bombs_position=nil)
      raise "num_mines should be <= width*height" if num_mines > width*height
      @width = width
      @height = height
      @num_mines = num_mines

      init_board(bombs_position)
      set_neighbor_bombs
    end

    def state(row, col)
      @board_cells[row][col].state
    end
    
    def board_state(config)
      xray = false
      xray = config[:xray] if config.key?(:xray)

      @board_cells.map do |line|
        line.map{|cell| cell.state(xray)}
      end
    end

    def count_bombs
      bombs = 0
      @board_cells.each do |line|
        line.each do |cell|
          bombs += 1 if cell.bomb?
        end
      end
      bombs
    end

    def expand(row, col)
      @board_cells[row][col].play
    end

    def toggle_flag(row, col)
      @board_cells[row][col].toggle_flag
    end

    private
    def init_board(bombs_position)
      #@board_cells = Array.new(@height) { Array.new(@width) }

      if bombs_position.nil? then
        bombs_position = random_bombs_position
      end

      @board_cells = bombs_position.map do |line|
        line.map do |bomb|
          has_bomb = (bomb == 1)
          Cell.new(has_bomb)
        end
      end
    end

    def random_bombs_position
      num_non_mines = @width*@height - @num_mines
      shuffled_bombs = (Array.new(@num_mines){1} + Array.new(num_non_mines){0}).shuffle
      shuffled_bombs.each_slice(@width).to_a
    end

    def set_neighbor_bombs
      (0..(@height-1)).each do |i|
        (0..(@width-1)).each do |j|
          increment_neighbors(i, j) if @board_cells[i][j].bomb?
        end
      end
    end

    def increment_neighbors(x, y)
      ((x-1)..(x+1)).each do |i|
        if i >=0 and i < @height then
          ((y-1)..(y+1)).each do |j|
            if j >= 0 and j < @width then
              @board_cells[i][j].neighbor_bombs += 1 if i != x or j != y
            end
          end
        end
      end
    end

    def expand_helper(candidates)
      while not candidates.empty? do
        current = candidates.shift
        row = current[0]
        col = current[1]
        neighbors = unvisited_neighbors(current)
        candidates += neighbors
        visit(@board[row][col])
      end
    end

    def unvisited_neighbors(point)
      row = point[0]
      col = point[1]
      neighbors = []

      (row-1)..(row+1).each do |i|
        (col-1)..(col+1).each do |j|
          if (i != row or j!= col) and (not @board[i][j].bomb?) and (not @board[i][j].open?) then
            neighbors.push(@board[i][j])
          end
        end
      end  
    end

  end
end