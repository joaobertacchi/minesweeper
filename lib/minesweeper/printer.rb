module Minesweeper
  class Printer
    def print(board_state)
      raise 'not implemented'
    end
  end

  class SimplePrinter < Printer

    def initialize
      @board_format = {
        unknown_cell: '.',
        clear_cell: ' ',
        bomb: '#',
        flag: 'F'
      }
    end

    def print(board_state)
      board_state.each do |line|
        puts "%s "*line.size % line.map{|cell| (cell.is_a?(Numeric) ? cell.to_s : @board_format[cell]) }
      end
    end

  end

  class PrettyPrinter < Printer
    # def initialize
    # end
  end
end