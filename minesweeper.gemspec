# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minesweeper/version'

Gem::Specification.new do |spec|
  spec.name          = "minesweeper"
  spec.version       = Minesweeper::VERSION
  spec.authors       = ["João Eduardo Ferreira Bertacchi"]
  spec.email         = ["joaobertacchi@gmail.com"]

  spec.summary       = "Library to create a Minesweeper game"
  spec.description   = %q{Minesweeper library to create minesweeper games.}
  spec.homepage      = "Thttps://bitbucket.org/joaobertacchi/minesweeper"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  #spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables << "sample_cli"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "autotest-standalone", "~> 4.5"
  spec.add_development_dependency "rspec-autotest", "~> 1.0"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency 'yard-contracts', '~> 0.1.5'
  spec.add_development_dependency 'pry', '~> 0.11.2'
end
