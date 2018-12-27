# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mtg_db/version'

Gem::Specification.new do |spec|
  spec.name          = 'mtg_db'
  spec.version       = MtgDb::VERSION
  spec.authors       = ['Byron Hammond']
  spec.email         = ['byronester@gmail.com']
  spec.summary       = %q{Create an SQLite3 database of all the MtG cards listed on The Gatherer}
  spec.description   = %q{Spiders The Gatherer collecting info about MtG cards which are then put in an SQLite3 Db}
  spec.homepage      = 'https://github.com/Hammit/mtg-database'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'minitest', '~> 5.4'
  spec.add_development_dependency 'pry', '0.10'
  spec.add_development_dependency 'pry-byebug', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.61.1'

  spec.add_dependency 'activesupport', '~> 5.2'
  spec.add_dependency 'mechanize', '~> 2.7'
  spec.add_dependency 'sequel', '~> 5.15'
  spec.add_dependency 'sqlite3', '~> 1.3'
  spec.add_dependency 'thor', '~> 0.20'
end
