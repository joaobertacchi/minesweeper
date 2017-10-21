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
    expect{
    Minesweeper::SimplePrinter.new(true).print(@board_state)
  }.to output("# . 3 F  \n4 4 4 4 4\n").to_stdout
end
end

end

describe Minesweeper::PrettyPrinter do
  
  it 'has PrettyPrinter class' do
    expect(Minesweeper::PrettyPrinter.new).not_to eq(nil)
  end
  
end