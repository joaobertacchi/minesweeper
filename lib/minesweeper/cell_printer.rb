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
end