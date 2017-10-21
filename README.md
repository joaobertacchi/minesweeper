# Minesweeper

Minesweeper is a library to help you creating your brand new minesweeper game.
For creating a new game, the only thing you need is a game object.

Use the following example from bin/sample_cli as a guideline. To test sample_cli
without installing minesweeper gem, run:

```bash
git clone https://bitbucket.org/joaobertacchi/minesweeper.git
cd minesweeper
ruby -Ilib ./bin/sample_cli
```

```ruby
require 'minesweeper'

puts "Type width, height, num_mines separated by spaces:"
width, height, num_mines = gets.split(' ').map{|e| e.to_i}
game = Minesweeper::Game.new(width, height, num_mines)
printer = Minesweeper::SimplePrinter.new

while game.still_playing?
  printer.print(game.board_state)
  puts
  puts "What is your next move:"
  type, row, col = gets.split(' ')
  if type == 'F' then
    valid_flag = game.flag(row.to_i, col.to_i)
  elsif type == 'P' then
    valid_move = game.play(row.to_i, col.to_i)
  else
    valid_move = false
  end
  
  if not valid_move
    puts 'Invalid move!!! Try again!'
  end
end

puts "Fim do jogo!"
if game.victory?
  puts "Você venceu!"
  printer.print(game.board_state(xray: true))
else
  puts "Você perdeu! As minas eram:"
  printer.print(game.board_state(xray: true))
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minesweeper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minesweeper

## Usage

To access Minesweeper API, run `bundle exec yardoc`. It creates html documentation in doc directory. Open doc/index.html in your web browser.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on BitBucket at https://bitbucket.org/joaobertacchi/minesweeper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

