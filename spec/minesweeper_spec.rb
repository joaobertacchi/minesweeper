require "spec_helper"

RSpec.describe Minesweeper do
  it "has a version number" do
    expect(Minesweeper::VERSION).not_to be nil
  end

  describe Minesweeper::Game do

    before :each do
      width, height, num_mines = 10, 20, 50
      @game = Minesweeper::Game.new(width, height, num_mines)
    end

    [ :still_playing?, :play, :flag, :board_state, :width, :height, :num_mines, :victory? ].each do |method|
      it "responds to #{method}" do
        expect(@game).to respond_to method
      end
    end

    describe "#initialize" do
      it "creates a valid game" do
        expect(@game.width).to eq(10)
        expect(@game.height).to eq(20)
        expect(@game.num_mines).to eq(50)
      end

      it "with bigger than allowed num_mines value" do
        expect{ Minesweeper::Game.new(5,5,26) }.to raise_error(RuntimeError)
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

    describe "#still_playing?" do
      it "tests if game is playing" do
        expect(@game.still_playing?).to eq(true)
      end
    end
    
    describe "#play" do
      it "triggers a game play" do
        expect(@game.play(1, 1)).to eq(true)
      end
    end

    describe "#flag" do
      it "puts a flag in the current game" do
        expect(@game.flag(1, 1)).to eq(true)
      end
    end

    describe "#board_state" do
      it "get the board state" do
        expect(@game).to respond_to(:board_state)
      end

      it "get the complete board state" do
        #expect(@game.board_state(xray: true)).not_to eq(nil)
        expect(@game).to respond_to(:board_state)
      end

    end

  end

  describe Minesweeper::Cell do
    describe "#bomb?" do
      it "has a bomb" do
        expect(Minesweeper::Cell.new(true).bomb?).to eq(true)
      end

      it "does not have a bomb" do
        expect(Minesweeper::Cell.new(false).bomb?).to eq(false)
      end
    end
  end

  describe Minesweeper::SimplePrinter do

    it "has SimplePrinter class" do
      expect(Minesweeper::SimplePrinter.new).not_to eq(nil)
    end

  end

  describe Minesweeper::PrettyPrinter do

    it "has PrettyPrinter class" do
      expect(Minesweeper::PrettyPrinter.new).not_to eq(nil)
    end
    
  end

end
