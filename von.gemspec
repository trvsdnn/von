# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'von/version'

Gem::Specification.new do |gem|
  gem.name          = "von"
  gem.version       = Von::VERSION
  gem.authors       = ["blahed"]
  gem.email         = ["tdunn13@gmail.com"]
  gem.description   = "Von is an opinionated Redis stats tracker."
  gem.summary       = "Von is an opinionated Redis stats tracker."
  gem.homepage      = "https://github.com/blahed/von"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 1.9.2'

  gem.add_dependency 'redis', '~> 3.0.2'
  gem.add_dependency 'activesupport', '~> 4.1.0'

  gem.add_development_dependency 'rake', '>= 10.0.3'
  gem.add_development_dependency 'minitest', '>= 3.0.0'
  gem.add_development_dependency 'fakeredis', '>= 0.4.1'
  gem.add_development_dependency 'mocha', '>= 0.11.4'
  gem.add_development_dependency 'timecop', '>= 0.5.9.1'
end
