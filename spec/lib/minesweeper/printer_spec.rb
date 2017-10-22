require 'spec_helper'
require 'minesweeper/printer'

describe Minesweeper::SimplePrinter do
  before :each do
    @board_state = [
      [:bomb, :unknown_cell, 3, :flag, :clear_cell],
      [4, 4, 4, 4, 4]
    ]
  end

  it 'has SimplePrinter class' do
    expect(Minesweeper::SimplePrinter.new).not_to eq(nil)
  end

  describe '#print' do
    it 'all states' do
      expect do
        Minesweeper::SimplePrinter.new(true).print(@board_state)
      end.to output("# . 3 F  \n4 4 4 4 4\n").to_stdout
    end
  end
end

describe Minesweeper::PrettyPrinter do
  it 'has PrettyPrinter class' do
    expect(Minesweeper::PrettyPrinter.new).not_to eq(nil)
  end
  describe '#print' do
    it 'single number (1)' do
      board_state = [[1]]
      expect do
        Minesweeper::PrettyPrinter.new.print(board_state)
      end.to output(
        '      0|'.colorize(:light_black) + "\n" + 
        '    ---|'.colorize(:light_black) + "\n" +
        '  0|'.colorize(:light_black) + ' ' + '1'.colorize(:light_white) + ' ' + '|'.colorize(:light_black) + "\n" +
        '   |---|'.colorize(:light_black) + "\n").to_stdout
    end
    it 'single bomb' do
      board_state = [[:bomb]]
      expect do
        Minesweeper::PrettyPrinter.new.print(board_state)
      end.to output(
        '      0|'.colorize(:light_black) + "\n" + 
        '    ---|'.colorize(:light_black) + "\n" +
        '  0|'.colorize(:light_black) + ' ' + 'o'.colorize(:light_red) + ' ' + '|'.colorize(:light_black) + "\n" +
        '   |---|'.colorize(:light_black) + "\n").to_stdout
    end
    it 'single flag' do
      board_state = [[:flag]]
      expect do
        Minesweeper::PrettyPrinter.new.print(board_state)
      end.to output(
        '      0|'.colorize(:light_black) + "\n" + 
        '    ---|'.colorize(:light_black) + "\n" +
        '  0|'.colorize(:light_black) + ' ' + 'P'.colorize(:light_yellow) + ' ' + '|'.colorize(:light_black) + "\n" +
        '   |---|'.colorize(:light_black) + "\n").to_stdout
    end
    it 'single closed cell' do
      board_state = [[:unknown_cell]]
      expect do
        Minesweeper::PrettyPrinter.new.print(board_state)
      end.to output(
        '      0|'.colorize(:light_black) + "\n" + 
        '    ---|'.colorize(:light_black) + "\n" +
        '  0|'.colorize(:light_black) + ' ' + '.' + ' ' + '|'.colorize(:light_black) + "\n" +
        '   |---|'.colorize(:light_black) + "\n").to_stdout
    end
    it 'single clear cell' do
      board_state = [[:clear_cell]]
      expect do
        Minesweeper::PrettyPrinter.new.print(board_state)
      end.to output(
        '      0|'.colorize(:light_black) + "\n" + 
        '    ---|'.colorize(:light_black) + "\n" +
        '  0|'.colorize(:light_black) + ' ' + ' ' + ' ' + '|'.colorize(:light_black) + "\n" +
        '   |---|'.colorize(:light_black) + "\n").to_stdout
    end
  end
end
