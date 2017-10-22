require 'colorize'
require 'contracts'

module Minesweeper
  class Printer
    include Contracts::Core
    include Contracts::Builtin
    C = Contracts

    def initialize(raw = false)
      @board_format = {
        unknown_cell: '.',
        clear_cell: ' ',
        bomb: '#',
        flag: 'F'
      }
      @raw = raw
    end

    Contract C::ArrayOf[C::ArrayOf[Or[Symbol, C::Pos]]] => C::Any
    def print(board_state)
      print_header(2, board_state) unless @raw

      board_state.each_with_index do |line, index|
        line_str = line_body(line, index)
        puts (@raw ? '' : transform(line_header(index))) + line_str
        line_sep = line_separator(board_state)
        puts line_sep unless line_sep.nil?
      end
    end

    protected

    def transform(text)
      text
    end

    def line_separator(board_state = nil); end

    def line_body(line, _index)
      line.map { |cell| (cell.is_a?(Numeric) ? cell.to_s : @board_format[cell]) }.join(' ')
    end

    def print_header(space, board_state)
      header(space, board_state).each do |line|
        puts transform(line)
      end
    end

    def header(space, board_state)
      [' ' * space + (0..(board_state[0].size - 1)).to_a.join(' '),
       ' ' * space + '_' * (board_state[0].size * 2 - 1)]
    end

    def line_header(line_number)
      line_number.to_s + '|'
    end
  end

  # Class used for printing a board_state.
  # Refer to Minesweeper::Game#board_state for checking board_state format.
  #
  # This printer uses the following symbols:
  # - # : bomb
  # - F : flag
  # - <number> : number of neighbor bombs
  # - . : closed cell
  #
  # Example
  #
  #    0 1 2 3 4
  #    _________
  #  0|F 1      
  #  1|2 2      
  #  2|# 1      
  #  3|1 1   1 1
  #  4|      1 #
  #  
  #  5 x 5 board_state with all states
  #
  class SimplePrinter < Printer
    include Contracts::Core
    include Contracts::Builtin
    C = Contracts
  end

  # Class used for printing a board_state.
  # Refer to Minesweeper::Game#board_state for checking board_state format.
  #
  # This printer uses the following color code and symbols:
  # - red (b) : bomb
  # - yellow (P) : flag
  # - white (<number>) : number of neighbor bombs
  # - white (.) : closed cell
  #
  # Example 1
  #
  #       0|  1|  2|  3|  4|
  #     ---|---|---|---|---|
  #   0| . | . | . | . | . |
  #    |---|---|---|---|---|
  #   1| . | . | . | . | . |
  #    |---|---|---|---|---|
  #   2| . | . | . | . | . |
  #    |---|---|---|---|---|
  #   3| . | . | . | . | . |
  #    |---|---|---|---|---|
  #   4| . | . | . | . | . |
  #    |---|---|---|---|---|
  #   
  #   5 x 5 board_state with all cells closed
  #
  # Example 2
  #
  #       0|  1|  2|
  #     ---|---|---|
  #   0|   |   |   |
  #    |---|---|---|
  #   1| 1 | 1 | 1 |
  #    |---|---|---|
  #   2| 1 | P | 1 |
  #    |---|---|---|
  #   3| 2 | 2 | 2 |
  #    |---|---|---|
  #   4| 1 | b | 1 |
  #    |---|---|---|
  #   
  #   5 x 3 board_state with open cells, a flag (P), a bomb (b), and numbers
  #
  class PrettyPrinter < Printer
    include Contracts::Core
    include Contracts::Builtin
    C = Contracts

    def initialize(raw = false)
      @board_format = {
        unknown_cell: '.',
        clear_cell: ' ',
        bomb: 'o'.colorize(:light_red),
        flag: 'P'.colorize(:light_yellow)
      }
      @raw = raw
    end

    protected

    def transform(text)
      text.colorize(:light_black)
    end

    def line_separator(board_state)
      transform('   |' + '---|' * board_state[0].size)
    end

    def header(_space, board_state)
      ['    ' + (('%3d|' * board_state[0].size) % (0..(board_state[0].size - 1)).to_a),
       '    ' + '---|' * board_state[0].size]
    end

    def line_header(line_number)
      format('%3d|', line_number)
    end

    def line_body(line, _index)
      (((' %s ' + transform('|')) * line.size) % line.map { |cell| (cell.is_a?(Numeric) ? cell.to_s.colorize(:light_white) : @board_format[cell]) })
    end
  end
end
