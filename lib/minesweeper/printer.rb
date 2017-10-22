require 'colorize'

module Minesweeper
  class Printer

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
        line_str = line_body(line, index)
        puts (@raw ? '' : transform(line_header(index))) + line_str
        line_sep = line_separator(board_state)
        puts line_sep if not line_sep.nil?
      end
    end

    protected
    def transform(text)
      text
    end

    def line_separator(board_state=nil)
    end

    def line_body(line, index)
      "%s "*line.size % line.map{|cell| (cell.is_a?(Numeric) ? cell.to_s : @board_format[cell]) }
    end

    def print_header(space, board_state)
      header(space, board_state).each do |line|
        puts transform(line)
      end
    end

    def header(space, board_state)
      [ ' '*space + (0..(board_state[0].size-1)).to_a.join(' '),
        ' '*space + '_' * (board_state[0].size * 2 - 1)]
    end

    def line_header(line_number)
      line_number.to_s + '|'
    end
  end

  class SimplePrinter < Printer
  end

  class PrettyPrinter < Printer

    def initialize(raw=false)
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
      transform('   |' + '---|'*board_state[0].size)
    end

    def header(space, board_state)
      [ '    ' + (("%3d|"*board_state[0].size) % (0..(board_state[0].size-1)).to_a),
        '    ' + '---|'*board_state[0].size]
    end

    def line_header(line_number)
      "%3d|" % line_number
    end

    def line_body(line, index)
      (((" %s " + transform("|"))*line.size) % line.map{|cell| (cell.is_a?(Numeric) ? cell.to_s.colorize(:light_white) : @board_format[cell]) })
    end
  end
end