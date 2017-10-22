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

