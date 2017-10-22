require 'spec_helper'
require 'minesweeper/cell'

describe Minesweeper::Cell do
  before :each do
    @cell = Minesweeper::Cell.new(bomb = false)
  end
  %i[bomb? open? flag? play toggle_flag neighbor_bombs neighbor_bombs=].each do |method|
    it "responds to #{method}" do
      expect(@cell).to respond_to method
    end
  end
  describe '#bomb?' do
    it 'has a bomb' do
      expect(Minesweeper::Cell.new(true).bomb?).to eq(true)
    end
    it 'does not have a bomb' do
      expect(Minesweeper::Cell.new(false).bomb?).to eq(false)
    end
  end
  describe '#open?' do
    it 'is open' do
      cell = Minesweeper::Cell.new(bomb = false, flag = false, open = true)
      expect(cell.open?).to eq(true)
    end
    it 'is not open' do
      cell = Minesweeper::Cell.new(bomb = false, flag = false, open = false)
      expect(cell.open?).to eq(false)
    end
  end
  describe '#toggle_flag' do
    it 'open cell does not toggle flag' do
      cell = Minesweeper::Cell.new(bomb = false, flag = false, open = true)
      expect(cell.toggle_flag).to eq(false)
      expect(cell.flag?).to eq(false)
    end
    it 'closed cell toggles flag' do
      cell_without_flag = Minesweeper::Cell.new(bomb = false, flag = false, open = false)
      cell_with_flag = Minesweeper::Cell.new(bomb = false, flag = true, open = false)
      expect(cell_without_flag.toggle_flag).to eq(true)
      expect(cell_without_flag.flag?).to eq(true)
      expect(cell_with_flag.toggle_flag).to eq(true)
      expect(cell_with_flag.flag?).to eq(false)
    end
  end
  describe '#play' do
    describe 'valid plays' do
      it 'closed cell with no flag' do
        cell_without_bomb = Minesweeper::Cell.new(bomb = false)
        cell_with_bomb = Minesweeper::Cell.new(bomb = true)
        expect(cell_without_bomb.play).to eq(true)
        expect(cell_with_bomb.play).to eq(true)
      end
    end
    describe 'unvalid plays' do
      it 'closed cell with flag' do
        cell_without_bomb = Minesweeper::Cell.new(bomb = false, flag = true)
        cell_with_bomb = Minesweeper::Cell.new(bomb = true, flag = true)
        expect(cell_without_bomb.play).to eq(false)
        expect(cell_with_bomb.play).to eq(false)
      end
      it 'open cell' do
        cell_without_bomb = Minesweeper::Cell.new(bomb = false, open = true)
        cell_with_bomb = Minesweeper::Cell.new(bomb = true, open = true)
        expect(cell_without_bomb.play).to eq(false)
        expect(cell_with_bomb.play).to eq(false)
      end
    end
  end
  describe '#state' do
    it 'unknown cell' do
      cell = Minesweeper::Cell.new(bomb = false, flag = false, open = false, neighbor_bombs = 0)
      expect(cell.state).to eq(:unknown_cell)
    end
    it 'clear cell' do
      cell = Minesweeper::Cell.new(bomb = false, flag = false, open = true, neighbor_bombs = 0)
      expect(cell.state).to eq(:clear_cell)
    end
    it 'numeric cell' do
      cell = Minesweeper::Cell.new(bomb = false, flag = false, open = true, neighbor_bombs = 3)
      expect(cell.state).to eq(3)
    end
    it 'bomb cell' do
      cell = Minesweeper::Cell.new(bomb = true, flag = false, open = true, neighbor_bombs = 0)
      expect(cell.state).to eq(:bomb)
    end
    it 'flag cell' do
      cell_with_bomb = Minesweeper::Cell.new(bomb = true, flag = true, open = false, neighbor_bombs = 0)
      cell_without_bomb = Minesweeper::Cell.new(bomb = false, flag = true, open = false, neighbor_bombs = 0)
      expect(cell_with_bomb.state).to eq(:flag)
      expect(cell_without_bomb.state).to eq(:flag)
    end
    it 'with xray' do
      empty_cell = Minesweeper::Cell.new(bomb = false, flag = false, open = false, neighbor_bombs = 0)
      numeric_cell = Minesweeper::Cell.new(bomb = false, flag = false, open = false, neighbor_bombs = 4)
      bomb_cell = Minesweeper::Cell.new(bomb = true, flag = false, open = false, neighbor_bombs = 0)
      flag_and_bomb_cell = Minesweeper::Cell.new(bomb = true, flag = true, open = false, neighbor_bombs = 0)
      flag_and_empty_cell = Minesweeper::Cell.new(bomb = false, flag = true, open = false, neighbor_bombs = 0)
      flag_and_numeric_cell = Minesweeper::Cell.new(bomb = false, flag = true, open = false, neighbor_bombs = 3)
      expect(empty_cell.state(true)).to eq(:unknown_cell)
      expect(numeric_cell.state(true)).to eq(:unknown_cell)
      expect(bomb_cell.state(true)).to eq(:bomb)
      expect(flag_and_bomb_cell.state(true)).to eq(:bomb)
      expect(flag_and_empty_cell.state(true)).to eq(:flag)
      expect(flag_and_numeric_cell.state(true)).to eq(:flag)
    end
  end
end
