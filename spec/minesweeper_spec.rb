require 'spec_helper'
require 'minesweeper'

RSpec.describe Minesweeper do
  it 'has a version number' do
    expect(Minesweeper::VERSION).not_to be nil
  end

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

  describe Minesweeper::Cell do

    before :each do
      @cell = Minesweeper::Cell.new(bomb=false)
    end

    [ :bomb?, :open?, :flag?, :play, :toggle_flag, :neighbor_bombs, :neighbor_bombs= ].each do |method|
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
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true)
        expect(cell.open?).to eq(true)
      end

      it 'is not open' do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=false)
        expect(cell.open?).to eq(false)
      end
    end

    describe '#toggle_flag' do
      it 'open cell does not toggle flag' do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true)
        expect(cell.toggle_flag).to eq(false)
        expect(cell.flag?).to eq(false)
      end
      it 'closed cell toggles flag' do
        cell_without_flag = Minesweeper::Cell.new(bomb=false, flag=false, open=false)
        cell_with_flag = Minesweeper::Cell.new(bomb=false, flag=true, open=false)
        expect(cell_without_flag.toggle_flag).to eq(true)
        expect(cell_without_flag.flag?).to eq(true)
        expect(cell_with_flag.toggle_flag).to eq(true)
        expect(cell_with_flag.flag?).to eq(false)
      end
    end

    describe '#play' do
      describe 'valid plays' do
        it 'closed cell with no flag' do
          cell_without_bomb = Minesweeper::Cell.new(bomb=false)
          cell_with_bomb = Minesweeper::Cell.new(bomb=true)
          expect(cell_without_bomb.play).to eq(true)
          expect(cell_with_bomb.play).to eq(true)
        end
      end

      describe 'unvalid plays' do
        it 'closed cell with flag' do
          cell_without_bomb = Minesweeper::Cell.new(bomb=false, flag=true)
          cell_with_bomb = Minesweeper::Cell.new(bomb=true, flag=true)
          expect(cell_without_bomb.play).to eq(false)
          expect(cell_with_bomb.play).to eq(false)
        end

        it 'open cell' do
          cell_without_bomb = Minesweeper::Cell.new(bomb=false, open=true)
          cell_with_bomb = Minesweeper::Cell.new(bomb=true, open=true)
          expect(cell_without_bomb.play).to eq(false)
          expect(cell_with_bomb.play).to eq(false)
        end
      end
    end

    describe '#state' do

      it 'unknown cell' do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=false, neighbor_bombs=0)
        expect(cell.state).to eq(:unknown_cell)
      end

      it 'clear cell' do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true, neighbor_bombs=0)
        expect(cell.state).to eq(:clear_cell)
      end

      it 'numeric cell' do
        cell = Minesweeper::Cell.new(bomb=false, flag=false, open=true, neighbor_bombs=3)
        expect(cell.state).to eq(3)
      end

      it 'bomb cell' do
        cell = Minesweeper::Cell.new(bomb=true, flag=false, open=true, neighbor_bombs=0)
        expect(cell.state).to eq(:bomb)
      end

      it 'flag cell' do
        cell_with_bomb = Minesweeper::Cell.new(bomb=true, flag=true, open=false, neighbor_bombs=0)
        cell_without_bomb = Minesweeper::Cell.new(bomb=false, flag=true, open=false, neighbor_bombs=0)
        expect(cell_with_bomb.state).to eq(:flag)
        expect(cell_without_bomb.state).to eq(:flag)
      end

      it 'with xray' do
        clear_cell = Minesweeper::Cell.new(bomb=false, flag=false, open=false, neighbor_bombs=0)
        numeric_cell = Minesweeper::Cell.new(bomb=false, flag=false, open=false, neighbor_bombs=4)
        bomb_cell = Minesweeper::Cell.new(bomb=true, flag=false, open=false, neighbor_bombs=0)
        flag_and_bomb_cell = Minesweeper::Cell.new(bomb=true, flag=true, open=false, neighbor_bombs=0)
        flag_and_clear_cell = Minesweeper::Cell.new(bomb=false, flag=true, open=false, neighbor_bombs=0)
        flag_and_numeric_cell = Minesweeper::Cell.new(bomb=false, flag=true, open=false, neighbor_bombs=3)
        expect(clear_cell.state(true)).to eq(:clear_cell)
        expect(numeric_cell.state(true)).to eq(4)
        expect(bomb_cell.state(true)).to eq(:bomb)
        expect(flag_and_bomb_cell.state(true)).to eq(:bomb)
        expect(flag_and_clear_cell.state(true)).to eq(:clear_cell)
        expect(flag_and_numeric_cell.state(true)).to eq(3)
      end

    end
  end

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
          Minesweeper::SimplePrinter.new.print(@board_state)
        }.to output("# . 3 F  \n4 4 4 4 4\n").to_stdout
      end
    end

  end

  describe Minesweeper::PrettyPrinter do

    it 'has PrettyPrinter class' do
      expect(Minesweeper::PrettyPrinter.new).not_to eq(nil)
    end
    
  end

  describe Minesweeper::Board do

    [:state, :expand, :toggle_flag].each do |method|
      it "responds to #{method}" do
        expect(Minesweeper::Board.new(1, 1, 0)).to respond_to method
      end
    end

    describe '#initialize' do

      it 'with static bombs' do
        bombs = [
          [1, 0, 0],
          [0, 0, 0],
          [0, 0, 1]
        ]
        board = Minesweeper::Board.new(3, 3, 2, bombs)
        expect(board.width).to eq(3)
        expect(board.height).to eq(3)
        expect(board.num_mines).to eq(2)
        expect(board.count_bombs).to eq(2)
      end

      it 'with random bombs' do
        board = Minesweeper::Board.new(10, 20, 25)
        expect(board.width).to eq(10)
        expect(board.height).to eq(20)
        expect(board.num_mines).to eq(25)
        expect(board.count_bombs).to eq(25)
      end
    end

    describe '#toggle_flag' do
      board = Minesweeper::Board.new(1, 1, 0)
      it 'set and unset a flag in the board' do
        expect(board.toggle_flag(0, 0)).to eq(true)
        expect(board.toggle_flag(0, 0)).to eq(true)
      end
    end

    describe '#expand' do
      it 'board with no bomb before expansion' do
        board = Minesweeper::Board.new(3,3,0)
        expect(board.board_state).to eq(
          [
            [:unknown_cell, :unknown_cell, :unknown_cell],
            [:unknown_cell, :unknown_cell, :unknown_cell],
            [:unknown_cell, :unknown_cell, :unknown_cell]
          ]
        )
      end

      it "board with no bomb after expansion" do
        board = Minesweeper::Board.new(3, 3, 0)
        board.expand(0, 0)
        expect(board.board_state).to eq(
          [
            [:clear_cell, :clear_cell, :clear_cell],
            [:clear_cell, :clear_cell, :clear_cell],
            [:clear_cell, :clear_cell, :clear_cell]
          ]
        )
      end

      it 'board with bombs after expansion (CASE 1)' do
        bombs = [
          [0,0,1,0,0],
          [0,0,1,0,0],
          [0,0,0,1,0],
          [0,0,1,0,0],
          [0,0,0,1,0]
        ]
        board = Minesweeper::Board.new(5, 5, 5, bombs)
        board.expand(0, 0)
        Minesweeper::SimplePrinter.new.print(board.board_state)
        expect(board.board_state).to eq(
          [
            [:clear_cell, 2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell, 2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell, 2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell, 1, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell, 1, :unknown_cell, :unknown_cell, :unknown_cell]
          ]
        )
      end

      it 'board with bombs after expansion (CASE 2)' do
        bombs = [
          [0,0,1,0,0],
          [0,0,1,0,0],
          [0,0,1,1,0],
          [0,0,0,0,1],
          [0,0,0,0,0]
        ]
        board = Minesweeper::Board.new(5, 5, 5, bombs)
        board.expand(0, 0)
        Minesweeper::SimplePrinter.new.print(board.board_state)
        expect(board.board_state).to eq(
          [
            [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,           3, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,           1,             2,             3, :unknown_cell],
            [:clear_cell, :clear_cell,   :clear_cell,             1, :unknown_cell]
          ]
        )
        board.expand(0, 4)
        puts
        Minesweeper::SimplePrinter.new.print(board.board_state)
        expect(board.board_state).to eq(
          [
            [:clear_cell,           2, :unknown_cell,             2,   :clear_cell],
            [:clear_cell,           3, :unknown_cell,             4,             1],
            [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,           1,             2,             3, :unknown_cell],
            [:clear_cell, :clear_cell,   :clear_cell,             1, :unknown_cell]
          ]
        )
      end

      it 'board with a single flag in the middle (CASE 3)' do
        board = Minesweeper::Board.new(5, 5, 0)
        board.toggle_flag(2, 2)
        board.expand(0, 0)

        Minesweeper::SimplePrinter.new.print(board.board_state)
        expect(board.board_state).to eq(
          [
            [:clear_cell, :clear_cell, :clear_cell, :clear_cell, :clear_cell],
            [:clear_cell, :clear_cell, :clear_cell, :clear_cell, :clear_cell],
            [:clear_cell, :clear_cell,       :flag, :clear_cell, :clear_cell],
            [:clear_cell, :clear_cell, :clear_cell, :clear_cell, :clear_cell],
            [:clear_cell, :clear_cell, :clear_cell, :clear_cell, :clear_cell]
          ]
        )
      end

      it 'board with bombs and a flag in a correct place (CASE 4)' do
        bombs = [
          [0,0,1,0,0],
          [0,0,1,0,0],
          [0,0,0,1,0],
          [0,0,1,0,0],
          [0,0,0,1,0]
        ]
        board = Minesweeper::Board.new(5, 5, 5, bombs)
        board.toggle_flag(0, 2)
        board.expand(0, 0)
        Minesweeper::SimplePrinter.new.print(board.board_state)
        expect(board.board_state).to eq(
          [
            [:clear_cell, 2,         :flag, :unknown_cell, :unknown_cell],
            [:clear_cell, 2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell, 2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell, 1, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell, 1, :unknown_cell, :unknown_cell, :unknown_cell]
          ]
        )
      end

      it 'board with bombs and a flag in a wrong place (CASE 5)' do
        bombs = [
          [0,0,1,0,0],
          [0,0,1,0,0],
          [0,0,1,1,0],
          [0,0,0,0,1],
          [0,0,0,0,0]
        ]
        board = Minesweeper::Board.new(5, 5, 5, bombs)
        board.toggle_flag(4, 1)
        board.expand(0, 0)
        Minesweeper::SimplePrinter.new.print(board.board_state)
        expect(board.board_state).to eq(
          [
            [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,           3, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,           1, :unknown_cell, :unknown_cell, :unknown_cell],
            [:clear_cell,       :flag, :unknown_cell, :unknown_cell, :unknown_cell],
          ]
        )
      end
    end
  end
end
