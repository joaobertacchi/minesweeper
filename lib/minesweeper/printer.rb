module Minesweeper
  class Printer
    def print(board_state)
      raise 'not implemented'
    end
  end

  class SimplePrinter < Printer

    def initialize(raw=false)
      @board_format = {
        unknown_cell: '.',
        clear_cell: ' ',
        bomb: '#',
        flag: 'F'
      }
      @raw = raw
    end

    def print(board_state)
      print_header(2, board_state) if not @raw

      board_state.each_with_index do |line, index|
        line_str = "%s "*line.size % line.map{|cell| (cell.is_a?(Numeric) ? cell.to_s : @board_format[cell]) }
        puts (@raw ? '' : line_header(index)) + line_str[0..-2]
      end
    end

    private
    def print_header(space, board_state)
      puts ' '*space + (0..(board_state[0].size-1)).to_a.join(' ')
      puts ' '*space + '_' * (board_state[0].size * 2 - 1)
    end

    def line_header(line_number)
      line_number.to_s + '|'
    end

  end

  class PrettyPrinter < Printer
    # def initialize
    # end
  end
end