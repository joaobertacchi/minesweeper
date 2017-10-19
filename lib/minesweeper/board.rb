module Minesweeper
  
  class Board

    ##
    # width, height, and num_mines are integers. num_mines must be <= width*height
    # bombs_position is an matrix of height X width dimension. Its elements are
    # 1 to indicate a bomb and 0 to indicate no-bomb.
    
    def initialize(width, height, num_mines, bombs_position=nil)
      @width = width
      @height = height
      @num_mines = num_mines

      init_board(bombs_position)
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

  end
end