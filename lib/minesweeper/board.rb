require 'contracts'

module Minesweeper

  # Store the game board state
  class Board
    include Contracts::Core
    include Contracts::Builtin
    C = Contracts

    attr_reader :width, :height, :num_mines

    # @param width is a positive integer
    # @param height is a positive integer
    # @param num_mines is a non-negative integer. Must be less than or equal to width * height
    # @param bombs_position is an matrix of height X width dimensions. 1 indicates bomb and 0, no-bomb.
    Contract C::Pos, C::Pos, C::Nat, C::Maybe[C::ArrayOf[C::ArrayOf[C::Nat]]] => C::Any
    def initialize(width, height, num_mines, bombs_position=nil)
      raise "num_mines should be <= width*height" if num_mines > width*height
      @width = width
      @height = height
      @num_mines = num_mines
      @exploded = false

      @current_num_non_mines = @width*@height - @num_mines

      init_board(bombs_position)
      set_neighbor_bombs

      actual_num_mines = count_bombs
      actual_height = @board_cells.size
      actual_width = @board_cells[0].size
      raise "num_mines=#{@num_mines} and actual number of mines in bombs_position (#{actual_num_mines}) does not match" if actual_num_mines != @num_mines
      raise "height=#{@height} and actual height in bombs_position (#{actual_height}) does not match" if actual_height != @height
      raise "width=#{@width} and actual width in bombs_position (#{actual_width}) does not match" if actual_width != @width
    end

    # Indicates if any bomb in the board has exploded.
    # @return true if any bomb in the board has exploded. False otherwise.
    Contract C::None => C::Bool
    def exploded?
      @exploded
    end

    # Used for knowing if the game is finished.
    # @return the amount of closed cells that has no bomb.
    Contract C::None => C::Nat
    def closed_cells_without_bomb
      @current_num_non_mines
    end
    
    # Param config is ignored unless the game is over. In this case, closed cells
    # with bombs (with or without flag) return :bomb state.
    # @param config optional hash to enable xray feature. Works only if the game is finished
    # @return the current board representation as a height X width matrix.
    Contract C::Maybe[C::KeywordArgs[xray: C::Bool]] => C::ArrayOf[C::ArrayOf[Or[Symbol, C::Pos]]]
    def board_state(config={})
      xray = false
      xray = config[:xray] if config.key?(:xray)

      @board_cells.map do |line|
        line.map{|cell| cell.state(xray)}
      end
    end

    # Tries to open the cell. If it is clear, its neighbors are also opened.
    # @return true if the cell could be open.
    Contract C::Nat, C::Nat => C::Bool
    def expand(row, col)
      valid = play_and_track_non_mines_and_explosion(row, col)

      return false if not valid
      return valid if @exploded
      
      expansion_candidates = []
      cell_coordinate = [row, col]
      while not cell_coordinate.nil?
        i = cell_coordinate[0]
        j = cell_coordinate[1]
        cell = @board_cells[i][j]
        if cell.state == :clear_cell then
          closed_neighbor_coordinates_without_bomb(i, j).each do |coordinate|
            x = coordinate[0]
            y = coordinate[1]

            play_and_track_non_mines_and_explosion(x, y)

            expansion_candidates.push(coordinate)
          end
        end
        cell_coordinate = expansion_candidates.shift
      end

      valid
    end

    # Toggles the flag status. An open cell cannot be flagged.
    # @return true if flag status could be toggled. False otherwise.
    Contract C::Nat, C::Nat => C::Bool
    def toggle_flag(row, col)
      @board_cells[row][col].toggle_flag
    end

    private
    def play_and_track_non_mines_and_explosion(row, col)
      is_valid = @board_cells[row][col].play

      if is_valid then
        @current_num_non_mines -= 1 if (not @board_cells[row][col].bomb?)
        @exploded = @board_cells[row][col].bomb? if not @exploded
      end

      is_valid
    end

    def state(row, col)
      @board_cells[row][col].state
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

    def init_board(bombs_position)
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
      initial_num_non_mines = @width*@height - @num_mines
      shuffled_bombs = (Array.new(@num_mines){1} + Array.new(initial_num_non_mines){0}).shuffle
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

    def neighbor_coordinates(row, col)
      neighbors = []
      ((row-1)..(row+1)).each do |i|
        if i >= 0 and i < @height then
          ((col-1)..(col+1)).each do |j|
            if j >= 0 and j < @width then
              neighbors.push([i, j]) if ((i != row) or (j != col))
            end
          end
        end
      end
      neighbors
    end

    def closed_neighbor_coordinates_without_bomb(row, col)
      neighbor_coordinates(row, col).select do |coordinate|
        i = coordinate[0]
        j = coordinate[1]
        not @board_cells[i][j].open? and not @board_cells[i][j].bomb? and not @board_cells[i][j].flag?
      end
    end
  end
end