# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tres_delta/version'

Gem::Specification.new do |spec|
  spec.name          = "tres_delta"
  spec.version       = TresDelta::VERSION
  spec.authors       = ["1000Bulbs", "Zachary Danger Campbell"]
  spec.email         = ["zacharydangercampbell@gmail.com"]
  spec.description   = %q{A Ruby client for 3Delta's credit card vault and payment gateway.}
  spec.summary       = %q{If you need to talk to 3Delta's credit card vault/payment gateway in Ruby... this is an ok start.}
  spec.homepage      = "https://github.com/1000Bulbs/tres-delta"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "savon", "2.3.3"

  spec.add_development_dependency "bundler", "~> 1.4"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
