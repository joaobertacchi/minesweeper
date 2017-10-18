require "spec_helper"
require "minesweeper"

RSpec.describe Minesweeper do
  it "has a version number" do
    expect(Minesweeper::VERSION).not_to be nil
  end

  describe Minesweeper::Game do

    before :each do
      width, height, num_mines = 10, 20, 50
      @game = Minesweeper::Game.new(width, height, num_mines)
      @game.board_state
    end

    [ :still_playing?, :play, :flag, :board_state, :width, :height, :num_mines, :width=, :height=, :num_mines=, :victory? ].each do |method|
      it "responds to #{method}" do
        expect(@game).to respond_to method
      end
    end

    describe "#initialize" do
      it "creates a valid game" do
        expect(@game.width).to eq(10)
        expect(@game.height).to eq(20)
        expect(@game.num_mines).to eq(50)
        expect(@game.count_bombs).to eq(50)
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
        expect(@game.play(1, 1)).to eq(false)
      end
    end

    describe "#flag" do
      it "puts a flag in the current game" do
        expect(@game.flag(1, 1)).to eq(true)
        expect(@game.play(1, 1)).to eq(false)
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

    before :each do
      @cell = Minesweeper::Cell.new(bomb=false)
    end

    [ :bomb?, :open?, :flag?, :play, :toggle_flag, :neighbor_bombs, :neighbor_bombs= ].each do |method|
      it "responds to #{method}" do
        expect(@cell).to respond_to method
      end
    end

    describe "#bomb?" do
      it "has a bomb" do
        expect(Minesweeper::Cell.new(true).bomb?).to eq(true)
      end

      it "does not have a bomb" do
        expect(Minesweeper::Cell.new(false).bomb?).to eq(false)
      end
    end

    describe "#open?" do
      it "is open" do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true)
        expect(cell.open?).to eq(true)
      end

      it "is not open" do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=false)
        expect(cell.open?).to eq(false)
      end
    end

    describe "#toggle_flag" do
      it "open cell does not toggle flag" do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true)
        expect(cell.toggle_flag).to eq(false)
        expect(cell.flag?).to eq(false)
      end
      it "closed cell toggles flag" do
        cell_without_flag = Minesweeper::Cell.new(bomb=false, flag=false, open=false)
        cell_with_flag = Minesweeper::Cell.new(bomb=false, flag=true, open=false)
        expect(cell_without_flag.toggle_flag).to eq(true)
        expect(cell_without_flag.flag?).to eq(true)
        expect(cell_with_flag.toggle_flag).to eq(true)
        expect(cell_with_flag.flag?).to eq(false)
      end
    end

    describe "#play" do
      describe "valid plays" do
        it "closed cell with no flag" do
          cell_without_bomb = Minesweeper::Cell.new(bomb=false)
          cell_with_bomb = Minesweeper::Cell.new(bomb=true)
          expect(cell_without_bomb.play).to eq(true)
          expect(cell_with_bomb.play).to eq(true)
        end
      end

      describe "unvalid plays" do
        it "closed cell with flag" do
          cell_without_bomb = Minesweeper::Cell.new(bomb=false, flag=true)
          cell_with_bomb = Minesweeper::Cell.new(bomb=true, flag=true)
          expect(cell_without_bomb.play).to eq(false)
          expect(cell_with_bomb.play).to eq(false)
        end

        it "open cell" do
          cell_without_bomb = Minesweeper::Cell.new(bomb=false, open=true)
          cell_with_bomb = Minesweeper::Cell.new(bomb=true, open=true)
          expect(cell_without_bomb.play).to eq(false)
          expect(cell_with_bomb.play).to eq(false)
        end
      end
    end
  end

  describe Minesweeper::CellPrinter do
    before :each do
      @printer = Minesweeper::CellPrinter.new
    end

    describe "#print" do
      it "closed cell" do
        cell = Minesweeper::Cell.new(bomb=false)
        expect(@printer.print(cell)).to eq(".")
      end
      it "closed and toggled cell" do
        cell = Minesweeper::Cell.new(bomb=false, flag=true)
        expect(@printer.print(cell)).to eq("F")
      end
      it "open and bomb cell" do
        cell = Minesweeper::Cell.new(bomb=true, flag=false, open=true)
        expect(@printer.print(cell)).to eq("#")
      end
      it "open and clear cell" do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true, neighbor_bombs=0)
        expect(@printer.print(cell)).to eq(" ")
      end
      it "open and 3 neighbor bombs cell" do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true, neighbor_bombs=3)
        expect(@printer.print(cell)).to eq("3")
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
