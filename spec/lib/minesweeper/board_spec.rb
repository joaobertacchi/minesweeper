require 'spec_helper'
require 'minesweeper/board'

describe Minesweeper::Board do

  [:board_state, :expand, :toggle_flag, :exploded?].each do |method|
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
    end

    it 'with random bombs' do
      board = Minesweeper::Board.new(10, 20, 25)
      expect(board.width).to eq(10)
      expect(board.height).to eq(20)
      expect(board.num_mines).to eq(25)
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