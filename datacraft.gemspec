# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datacraft/version'

Gem::Specification.new do |spec|
  spec.name          = 'datacraft'
  spec.version       = Datacraft::VERSION
  spec.authors       = ['Xiaoxing Hu']
  spec.email         = ['dawnstar.hu@gmail.com']

  spec.summary       = 'Minecraft for data.'
  spec.description   = 'Datacraft works like Minecraft but for data. '\
  'The workflow: Get data from source -> process them -> build the products '\
  'or parts that is used in another end product. '\
  'And you get to desgin the instructions with a comprehensive DSL.'
  spec.homepage      = 'https://github.com/xiaoxinghu/datacraft'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'pry'
end
