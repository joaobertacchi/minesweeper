require 'spec_helper'
require 'minesweeper/game'

describe Minesweeper::Game do
  before :each do
    width = 10
    height = 20
    num_mines = 50
    @game = Minesweeper::Game.new(width, height, num_mines)
  end
  %i[still_playing? play flag board_state victory?].each do |method|
    it "responds to #{method}" do
      expect(@game).to respond_to method
    end
  end
  describe '#initialize' do
    it 'with bigger than allowed num_mines value' do
      expect { Minesweeper::Game.new(5, 5, 26) }.to raise_error(RuntimeError)
    end
    it 'with non integer width' do
      expect { Minesweeper::Game.new(:a, 5, 25) }.to raise_error(ArgumentError)
    end
    it 'with non integer height' do
      expect { Minesweeper::Game.new(5, :a, 25) }.to raise_error(ArgumentError)
    end
    it 'with non integer num_mines' do
      expect { Minesweeper::Game.new(5, 5, :a) }.to raise_error(ArgumentError)
    end
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
    it 'throws exception for too big row' do
      expect { @game.play(20, 0) }.to raise_error(RuntimeError)
    end
    it 'throws exception for too big col' do
      expect { @game.play(19, 10) }.to raise_error(RuntimeError)
    end
    it 'throws exception for wrong params' do
      expect { @game.play(0) }.to raise_error(ArgumentError)
    end
  end
  describe '#flag' do
    it 'puts a flag in the current game' do
      expect(@game.flag(1, 1)).to eq(true)
      expect(@game.play(1, 1)).to eq(false)
    end
    it 'throws exception for too big row' do
      expect { @game.flag(20, 0) }.to raise_error(RuntimeError)
    end
    it 'throws exception for too big col' do
      expect { @game.flag(19, 10) }.to raise_error(RuntimeError)
    end
    it 'throws exception for wrong params' do
      expect { @game.flag(0) }.to raise_error(ArgumentError)
    end
  end
  describe '#board_state' do
    it 'get the complete board state' do
      expect(@game).to respond_to(:board_state)
    end
  end

  describe '#still_playing?' do
    it 'unfinished game' do
      game = Minesweeper::Game.new(10, 10, 10)
      expect(game.still_playing?).to eq(true)
    end

    it 'game with no bombs' do
      game = Minesweeper::Game.new(10, 10, 0)
      expect(game.still_playing?).to eq(true)
    end

    it 'finished with victory' do
      game = Minesweeper::Game.new(10, 10, 0)
      game.play(0, 0)
      expect(game.still_playing?).to eq(false)
    end

    it 'finished with defeat' do
      game = Minesweeper::Game.new(10, 10, 100)
      game.play(0, 0)
      expect(game.still_playing?).to eq(false)
    end
  end

  describe '#victory?' do
    it 'unfinished game' do
      game = Minesweeper::Game.new(10, 10, 10)
      expect(game.victory?).to eq(false)
    end

    it 'game with no bombs' do
      game = Minesweeper::Game.new(10, 10, 0)
      expect(game.victory?).to eq(false)
    end

    it 'finished with victory' do
      game = Minesweeper::Game.new(10, 10, 0)
      game.play(0, 0)
      expect(game.victory?).to eq(true)
    end

    it 'finished with defeat' do
      game = Minesweeper::Game.new(10, 10, 100)
      game.play(0, 0)
      expect(game.victory?).to eq(false)
    end
  end

  describe '#board_state' do
    it 'xray does not work for an unfinished game' do
      bombs = [
        [1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0]
      ]
      expected_board_state = [
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell]
      ]
      board = Minesweeper::Board.new(5, 5, 2, bombs)
      game = Minesweeper::Game.new(5, 5, 2)
      game.board = board
      expect(game.board_state(xray: true)).to eq(expected_board_state)
    end

    it 'xray works for finished game' do
      bombs = [
        [1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0]
      ]
      expected_board_state = [
        %i[bomb unknown_cell unknown_cell unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell bomb unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell],
        %i[unknown_cell unknown_cell unknown_cell unknown_cell unknown_cell]
      ]
      board = Minesweeper::Board.new(5, 5, 2, bombs)
      game = Minesweeper::Game.new(5, 5, 2)
      game.board = board
      game.play(0, 0) # Force game to finish with a explosion
      expect(game.board_state(xray: true)).to eq(expected_board_state)
    end
  end
end
