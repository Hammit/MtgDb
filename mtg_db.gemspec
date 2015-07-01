# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mtg_db/version'

Gem::Specification.new do |spec|
  spec.name          = "mtg_db"
  spec.version       = MtgDb::VERSION
  spec.authors       = ["Byron Hammond"]
  spec.email         = ["byronester@gmail.com"]
  spec.summary       = %q{Create an SQLite3 Db of all the MtG cards listed on the Gatherer.}
  spec.description   = %q{Spiders the Gatherer collecting info about MtG cards which are then put in an SQLite3 Db.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"

  spec.add_dependency "activesupport"
  spec.add_dependency "mechanize"
  spec.add_dependency "sqlite3"
  spec.add_dependency "sequel"
  spec.add_dependency "thor"
end
