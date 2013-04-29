# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ['Mikael Wikman']
  gem.email         = ['mikael@swedcontent.com']
  gem.description   = %q{Rule-based hash manipulator using custom DSL}
  gem.summary       = %q{ }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|features)/})
  gem.name          = "sc-hashrules"
  gem.require_paths = ["lib"]
  gem.version       = '1.0.0'
end
