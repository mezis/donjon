# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'donjon/version'

Gem::Specification.new do |spec|
  spec.name          = "donjon"
  spec.version       = Donjon::VERSION
  spec.authors       = ["Julien Letessier"]
  spec.email         = ["julien.letessier@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'gibberish'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
