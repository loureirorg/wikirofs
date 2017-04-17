# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikirofs/version'

Gem::Specification.new do |spec|
  spec.name          = "wikirofs"
  spec.version       = Wikirofs::VERSION
  spec.authors       = ["Daniel Loureiro"]
  spec.email         = ["loureirorg@gmail.com"]
  spec.licenses      = ['CC0-1.0']

  spec.summary       = %q{Wikipedia Virtual FileSystem (read-only)}
  spec.description   = %q{A virtual filesystem to mount wikipedia.}
  spec.homepage      = "http://www.learnwithdaniel.com"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.executables << 'mount.wikiro'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency     "nokogiri", "~> 1.7"
  spec.add_runtime_dependency     "rfusefs", "~> 1.0"
  spec.add_runtime_dependency     "httpclient", "~> 2.8"
end
