require 'spec_helper'
require 'minesweeper'

RSpec.describe Minesweeper do
  it 'has a version number' do
    expect(Minesweeper::VERSION).not_to be nil
  end
end
