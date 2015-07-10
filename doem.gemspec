# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doem/version'

Gem::Specification.new do |spec|
  spec.name          = 'doem'
  spec.version       = Doem::VERSION
  spec.authors       = ['Xiaoxing Hu']
  spec.email         = ['dawnstar.hu@gmail.com']

  spec.summary       = 'Data OEM (Original Equipment Manufacturer)'
  spec.description   = 'doem works like an OEM but for data, '\
  'get data from source, process them, build the products '\
  'or parts that is used in another end product.'\
  'You get to desgin the instructions with a comprehensive DSL.'
  spec.homepage      = 'https://github.com/xiaoxinghu/doem'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 0'
  spec.add_development_dependency 'pry', '~> 0'
end
