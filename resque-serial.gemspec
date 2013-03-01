# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque-serial/version'

Gem::Specification.new do |gem|
  gem.name          = "resque-serial"
  gem.version       = Resque::Serial::VERSION
  gem.authors       = ["Max Kazarin"]
  gem.email         = ["maxkazargm@gmail.com"]
  gem.description   = %q{Resque serial jobs}
  gem.summary       = %q{Resque serial jobs}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
