module Minesweeper
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