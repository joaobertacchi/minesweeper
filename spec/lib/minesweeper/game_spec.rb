require "spec_helper"
require "minesweeper/game"

describe Minesweeper::Game do
  
  before :each do
    width, height, num_mines = 10, 20, 50
    @game = Minesweeper::Game.new(width, height, num_mines)
    #Minesweeper::SimplePrinter.new.print(@game.board_state(xray: true))
  end
  
  [:still_playing?, :play, :flag, :board_state, :victory?].each do |method|
    it "responds to #{method}" do
      expect(@game).to respond_to method
    end
  end
  
  describe '#initialize' do
    
    it 'with bigger than allowed num_mines value' do
      expect{ Minesweeper::Game.new(5, 5, 26) }.to raise_error(RuntimeError)
    end
    
    # it "with non integer width" do
    #   expect{ Minesweeper::Game.new(:a,5,25) }.to raise_error(ArgumentError)
    # end
    
    # it "with non integer height" do
    #   expect{ Minesweeper::Game.new(5, :a,25) }.to raise_error(ArgumentError)
    # end
    
    # it "with non integer num_mines" do
    #   expect{ Minesweeper::Game.new(5, 5, :a) }.to raise_error(ArgumentError)
    # end
  end
  
  describe '#still_playing?' do
    it 'tests if game is playing' do
      expect(@game.still_playing?).to eq(true)
    end
  end
  
  describe '#play' do
    it 'triggers a game play' do
      expect(@game.play(1, 1)).to eq(true)
      expect(@game.play(1, 1)).to eq(false)
    end
  end
  
  describe '#flag' do
    it 'puts a flag in the current game' do
      expect(@game.flag(1, 1)).to eq(true)
      expect(@game.play(1, 1)).to eq(false)
    end
  end
  
  describe '#board_state' do
    it 'get the board state' do
      expect(@game).to respond_to(:board_state)
    end
    
    it 'get the complete board state' do
      #expect(@game.board_state(xray: true)).not_to eq(nil)
      expect(@game).to respond_to(:board_state)
    end
    
  end
  
end