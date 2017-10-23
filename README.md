# Minesweeper

Minesweeper is a library for you to create your brand new minesweeper game.
For creating a new game, the only thing you need is the Minesweeper::Game object.

Use the following example from bin/sample_cli as a guideline to create your own game.

```ruby
#!/usr/bin/env ruby

require 'minesweeper'

valid_input = false
while !valid_input do
  begin
    puts 'Type height, width, num_mines separated by spaces:'
    height, width, num_mines = STDIN.gets.chomp.split(' ').map(&:to_i)
    game = Minesweeper::Game.new(width, height, num_mines)
    printer = (ARGV[0] == '--pretty' ? Minesweeper::PrettyPrinter.new : Minesweeper::SimplePrinter.new)
    valid_input = true
  rescue => exception
    puts 'Wrong input. Try again!'
  end
end

while game.still_playing?
  printer.print(game.board_state)
  puts
  puts 'What is your next move:'
  begin
    type, row, col = STDIN.gets.chomp.split(' ')
    if type == 'F'
      valid_flag = game.flag(row.to_i, col.to_i)
    elsif type == 'P'
      valid_move = game.play(row.to_i, col.to_i)
    else
      valid_move = false
    end
  rescue => exception
    valid_move = false
  end

  puts 'Invalid move!!! Try again!' unless valid_move
end

puts 'Game over!'
if game.victory?
  puts 'You won!'
  printer.print(game.board_state(xray: true))
else
  puts 'You lose! Mine were at:'
  printer.print(game.board_state(xray: true))
end
```

To test sample_cli without installing minesweeper gem, run:

```bash
git clone https://bitbucket.org/joaobertacchi/minesweeper.git
cd minesweeper
ruby -Ilib ./bin/sample_cli
```

If you prefer to use a prettier printer:

```bash
ruby -Ilib ./bin/sample_cli --pretty
```


## Requirements Verification

This Minesweeper implementation was coded as an answer to an exercise. Here follows the
game requirements stated in the exercise and, when indicated, the the automated set of
tests that verify the related requirement.

All the requirements are written in portuguese since they were copied from the original
exercise description:

### Req. 1
    No início do jogo, a engine deve aceitar parâmetros de altura, largura e número de
    bombas no tabuleiro.

Requirement met by design. For creating a new game, the {Minesweeper::Game#initialize} (width, height, num_bombs) constructor must be used. All its params are mandatory. Other game interactions only can occur after creating a game object.

### Req. 2

    As bombas devem ser distribuídas aleatoriamente, de forma que todas as combinações
    de posições possíveis tenham a mesma probabilidade de acontecer.

Requirement met by design. A montecarlo test could be used for showing that the implementation
is correct. However, for simplicity, I prefered to demonstrate it by refering the code from {Minesweeper::Board#random_bombs_position}. Please see it!

```ruby
  def random_bombs_position
    initial_num_non_mines = @width * @height - @num_mines
    shuffled_bombs = (Array.new(@num_mines) { 1 } + Array.new(initial_num_non_mines) { 0 }).shuffle
    shuffled_bombs.each_slice(@width).to_a
  end
```

A matrix of height X width dimenstions with 0s and 1s is created. Zero means no bomb and
One means bomb. This matrix has exactly num_mines 1s randomly distributed. This matrix is
used by the boad constructor {Minesweeper::Cell#initialize} for creating objects with and
without bombs.

### Req. 3
    Sua engine deve expor um conjunto mínimo de métodos para o cliente: play, flag,
    still_playing?, victory?, state_board

Requirement is verified in ```spec/lib/minesweeper/game_spec.rb``` by the following set
of tests:

```ruby
%i[still_playing? play flag board_state victory?].each do |method|
  it "responds to #{method}" do
    expect(@game).to respond_to method
  end
end
```

### Req. 4
    - play: recebe as coordenadas x e y do tabuleiro e clica na célula correspondente;
    a célula passa a ser "descoberta". Deve retornar um booleano informando se a jogada
    foi válida. A jogada é válida somente se a célula selecionada ainda não foi clicada
    e ainda não tem uma bandeira. Caso a célula clicada seja válida, não tenha uma bomba
    e seja vizinha de zero bombas, todos os vizinhos sem bomba e sem bandeira daquela
    célula também devem ser descobertas, e devem seguir esta mesma lógica para seus
    próprios vizinhos (esse é o comportamento de expansão quando clicamos em uma grande
    área sem bombas no jogo de campo minado).

This interface if enforced by contracts.ruby gem. It is described at {Minesweeper::Game#play}

```ruby
Contract C::Nat, C::Nat => C::Bool
def play(row, col)
  raise "row must be less than #{@board.height}" if row >= @board.height
  raise "col must be less than #{@board.width}" if col >= @board.width
  return false unless @playing
  is_valid = @board.expand(row, col)
  @playing = !(@board.exploded? || (@board.closed_cells_without_bomb == 0))
  is_valid
end
```

{Minesweeper::Game#play} behavior is tested in several ways. At the Minesweeper::Cell
level, file ```spec/lib/minesweeper/cell_spec.rb``` performs the following tests.
They intend to verify valid and invalid plays.

```ruby
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
```

The expansion behavior is implemented at {Minesweeper::Board#expand}. It is verified
at ```spec/lib/minesweeper/board_spec.rb```:

```ruby
  describe '#expand' do
    it 'board with no bomb before expansion' do
      board = Minesweeper::Board.new(3, 3, 0)
      expect(board.board_state).to eq(
        [
          %i[unknown_cell unknown_cell unknown_cell],
          %i[unknown_cell unknown_cell unknown_cell],
          %i[unknown_cell unknown_cell unknown_cell]
        ]
      )
    end

    it 'board with no bomb after expansion' do
      board = Minesweeper::Board.new(3, 3, 0)
      board.expand(0, 0)
      expect(board.board_state).to eq(
        [
          %i[clear_cell clear_cell clear_cell],
          %i[clear_cell clear_cell clear_cell],
          %i[clear_cell clear_cell clear_cell]
        ]
      )
    end

    it 'board with bombs after expansion (CASE 1)' do
      bombs = [
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0]
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
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 1, 0],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0]
      ]
      board = Minesweeper::Board.new(5, 5, 5, bombs)
      board.expand(0, 0)
      Minesweeper::SimplePrinter.new.print(board.board_state)
      expect(board.board_state).to eq(
        [
          [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
          [:clear_cell,           3, :unknown_cell, :unknown_cell, :unknown_cell],
          [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
          [:clear_cell,           1, 2,             3, :unknown_cell],
          [:clear_cell, :clear_cell, :clear_cell, 1, :unknown_cell]
        ]
      )
      board.expand(0, 4)
      puts
      Minesweeper::SimplePrinter.new.print(board.board_state)
      expect(board.board_state).to eq(
        [
          [:clear_cell,           2, :unknown_cell,             2, :clear_cell],
          [:clear_cell,           3, :unknown_cell,             4, 1],
          [:clear_cell,           2, :unknown_cell, :unknown_cell, :unknown_cell],
          [:clear_cell,           1, 2,             3, :unknown_cell],
          [:clear_cell, :clear_cell, :clear_cell, 1, :unknown_cell]
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
          %i[clear_cell clear_cell clear_cell clear_cell clear_cell],
          %i[clear_cell clear_cell clear_cell clear_cell clear_cell],
          %i[clear_cell clear_cell flag clear_cell clear_cell],
          %i[clear_cell clear_cell clear_cell clear_cell clear_cell],
          %i[clear_cell clear_cell clear_cell clear_cell clear_cell]
        ]
      )
    end

    it 'board with bombs and a flag in a correct place (CASE 4)' do
      bombs = [
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0]
      ]
      board = Minesweeper::Board.new(5, 5, 5, bombs)
      board.toggle_flag(0, 2)
      board.expand(0, 0)
      Minesweeper::SimplePrinter.new.print(board.board_state)
      expect(board.board_state).to eq(
        [
          [:clear_cell, 2, :flag, :unknown_cell, :unknown_cell],
          [:clear_cell, 2, :unknown_cell, :unknown_cell, :unknown_cell],
          [:clear_cell, 2, :unknown_cell, :unknown_cell, :unknown_cell],
          [:clear_cell, 1, :unknown_cell, :unknown_cell, :unknown_cell],
          [:clear_cell, 1, :unknown_cell, :unknown_cell, :unknown_cell]
        ]
      )
    end

    it 'board with bombs and a flag in a wrong place (CASE 5)' do
      bombs = [
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 1, 0],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0]
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
          %i[clear_cell flag unknown_cell unknown_cell unknown_cell]
        ]
      )
    end
  end
```

Tests at ```lib/minesweeper/game_spec.rb``` for {Minesweeper::Game#play} verify
expected return values in case of right and wrong parameters.

```ruby
  before :each do
    width = 10
    height = 20
    num_mines = 50
    @game = Minesweeper::Game.new(width, height, num_mines)
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
```

### Req. 5
    - flag: adiciona uma bandeira a uma célula ainda não clicada ou remove a bandeira
    preexistente de uma célula. Retorna um booleano informando se a jogada foi válida.

This interface if enforced by contracts.ruby gem. It is described at {Minesweeper::Game#flag}.

```ruby
Contract C::Nat, C::Nat => C::Bool
def flag(row, col)
  raise "row must be less than #{@board.height}" if row >= @board.height
  raise "col must be less than #{@board.width}" if col >= @board.width
  return false unless @playing
  @board.toggle_flag(row, col)
end
```

{Minesweeper::Game#flag} behavior is tested in several ways. At the Minesweeper::Cell
level, file ```spec/lib/minesweeper/cell_spec.rb``` performs the following tests.
They intend to verify valid and invalid plays.

```ruby
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
```

Minesweeper::Board only propagate the {Minesweeper::Game#flag} call to {Minesweeper::Cell#toggle_flag}.
For this reason, minimum amount of tests are required at ```lib/minesweeper/board_spec.rb```.

```ruby
  describe '#toggle_flag' do
    board = Minesweeper::Board.new(1, 1, 0)
    it 'set and unset a flag in the board' do
      expect(board.toggle_flag(0, 0)).to eq(true)
      expect(board.toggle_flag(0, 0)).to eq(true)
    end
  end
```

Tests at ```lib/minesweeper/game_spec.rb``` for {Minesweeper::Game#flag} verify
expected return values in case of right and wrong parameters.

```ruby
  before :each do
    width = 10
    height = 20
    num_mines = 50
    @game = Minesweeper::Game.new(width, height, num_mines)
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
```

### Req. 6
    - still_playing?: retorna true se o jogo ainda está em andamento, ou false se o
    jogador tiver alcançado a condição de vitória (todas as células sem bomba foram
    descobertas) ou de derrota (jogador clicou em uma célula sem bandeira e ela tinha
    uma bomba).

This interface if enforced by contracts.ruby gem. It is described at
{Minesweeper::Game#still_playing?}. This behavior is implemented in Minesweeper::Game
object and tested at ```lib/minesweeper/game_spec.rb```.

```ruby
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
```

### Req. 7
    - victory?: retorna true somente se o jogo já acabou e o jogador ganhou.

This interface if enforced by contracts.ruby gem. It is described at
{Minesweeper::Game#victory?}. This behavior is implemented in Minesweeper::Game
object and tested at ```lib/minesweeper/game_spec.rb```.

```ruby
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
```

### Req. 8
    - board_state: retorna uma representação atual do tabuleiro, indicando quais células
    ainda não foram descobertas, se alguma foi descoberta e tem uma bomba, quais foram
    descobertas e têm células com bombas como vizinhas (indicar quantas são as vizinhas
    minadas), quais não estão descobertas e com bandeira. Se o cliente passar o hash
    {xray: true} como parâmetro, deve indicar a localização de todas as bombas, mas
    somente se o jogo estiver terminado.

This interface if enforced by contracts.ruby gem. Its behavior is implemented by 
{Minesweeper::Cell#state}, {Minesweeper::Board#board_state} and {Minesweeper::Game#board_state}
methods. Many state tests are performed in ```lib/minesweeper/cell_spec.rb``` at unit test
level:

```ruby
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
```

The xray feature depends on game status (playing or finished). For that reason, tests related
to this feature are implemented in ```lib/minesweeper/game_spec.rb``` file.

```ruby
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
      game.play(0, 0) # Force game to finish with an explosion
      expect(game.board_state(xray: true)).to eq(expected_board_state)
    end
  end
```

Notice that tests for {Minesweeper::Board#expand} in ```lib/minesweeper/board_spec.rb```
also test {Minesweeper::Board#board_state}.

### Req. 9
    3. Uma célula descoberta deve saber informar o número de bombas adjacentes a ela, se
    houver alguma (entre 1 e 8). Se não tiver bombas adjacentes, deve ser considerada uma
    célula descoberta e vazia.

The {Minesweeper::Cell#neighbor_bombs} method informs how many neighbor bombs a cell has.
The cell state is returned by calling {Minesweeper::Cell#state}.

The full board neighbor bombs status is calculated when a board is created
{Minesweeper::Board#initialize} in the private method
{Minesweeper::Board#set_neighbor_bombs} bellow:

```ruby
    def set_neighbor_bombs
      (0..(@height - 1)).each do |i|
        (0..(@width - 1)).each do |j|
          increment_neighbors(i, j) if @board_cells[i][j].bomb?
        end
      end
    end
```

### Req. 10
    4. Crie pelo menos dois tipos de objeto "printer" que mostrem no terminal o estado
    do tabuleiro. Esses printers servem como exemplo de como um cliente pode consumir o
    método "board_state" da sua engine. Por exemplo, um deles pode simplesmente imprimir
    uma matriz mapeando os estados para caracteres segundo a especificação:

    ```ruby
    board_format = {
      unknown_cell: '.',
      clear_cell: ' ',
      bomb: '#',
      flag: 'F'
    }
    ```

Classes {Minesweeper::SimplePrinter} and {Minesweeper::PrettyPrinter} were created for
complying with this requirement. Multiple tests were developed to ensure 
{Minesweeper::SimplePrinter#print} and {Minesweeper::PrettyPrinter#print} work correctly.
Please refer to ```lib/minesweeper/printer_spec.rb``` file to check these tests.

### Req. 11
    5. Ao efetuar uma jogada em uma bomba (sem bandeira), o jogo deve terminar e nenhuma
    outra jogada subsequente deve ser considerada válida.

This behavior is tested at ```lib/minesweeper/game_spec.rb``` with the following code:

```ruby
    it 'after a bomb explodes no further play/flag is allowed' do
      bombs = [
        [1, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0]
      ]
      board = Minesweeper::Board.new(5, 5, 2, bombs)
      game = Minesweeper::Game.new(5, 5, 2)
      game.board = board
      expect(game.play(0, 0)).to eq(true) # Open a bomb

      expect(game.still_playing?).to eq(false) # Game is over

      # No further move is allowed
      (0..4).each do |row|
        (0..4).each do |col|
          expect(game.play(row, col)).to eq(false)
          expect(game.flag(row, col)).to eq(false)
        end
      end
    end
```

### Req. 12
    6. Demonstre, da maneira que achar melhor, que o seu projeto funciona como especificado.

This whole section, Requirements Verification, shows how the requirements are verified.

## Installation

Currently minesweeper is not available at RubyGems.org.
That means you will have to install it from source.

Checkout the repo:

```bash
git clone https://bitbucket.org/joaobertacchi/minesweeper.git
```

And install it:

```bash
cd minesweeper
bundle exec rake install
```

## Usage

The only classe you need to create your game is Minesweeper::Game.
Minesweeper::SimplePrinter and Minesweeper::PrettyPrinter could also be handful
if you intend to create a console game. They get a game board state and print
it in a nice way to the console. Minesweeper::PrettyPrinter is the most
recommended since it creates a better presentation.

To make the Minesweeper module available in your code:

```ruby
require 'minesweeper'
```

Then you just need to create a game object:

```ruby
width, height, num_mines = 10, 15, 15
game = Minesweeper::Game.new(width, height, num_mines)
```

And use ```game.play(row, col)``` for clicking in a cell, ```game.flag(row, col)```
to put a flag in a cell, ```game.still_playing?``` to check if the game is still
running, ```game.victory?``` to check if the game finished with a won, and
```game.board_state``` to obtain the full board state at any time.

To print the board state you can do:

```ruby
printer = Minesweeper::PrettyPrinter.new
printer.print(game.board_state)
```

Please refer to Minesweeper API for further instructions. To access the API
documentation, first run `bundle exec yardoc` from minesweeper repo and then
open ```doc/index.html``` from your prefered web browser.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

After running `bundle exec rake spec`, coverage report will be created and
placed in ```coverage``` directory.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on BitBucket at https://bitbucket.org/joaobertacchi/minesweeper. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [Contributor Covenant](http://contributor-covenant.org)
code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

