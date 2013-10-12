# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'edgar/version'

Gem::Specification.new do |spec|
  spec.name          = "edgar"
  spec.version       = Edgar::VERSION
  spec.authors       = ["Andy Schrage"]
  spec.email         = ["ajschrag@mtu.edu"]
  spec.description   = %q{Edgar is a Ruby gem that provides access to historical stock data in a simple, configurable way.}
  spec.summary       = %q{Stock data since the beginning of time!}
  spec.homepage      = "https://github.com/Swimminschrage/edgar"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
end
