Gem::Specification.new do |s|
  s.name        = 'collabda'
  s.version     = '0.0.1a'
  s.date        = '2013-07-19'
  s.files       = ['lib/collabda.rb']
  s.test_files  = ['spec/lib/collabda_spec.rb']
  s.authors     = ['James Edwards-Jones']
  s.homepage    = 'https://github.com/Jamedjo/Collabda'
  s.summary     = 'A library for building models from data files'
  s.description = 'Collabda uses JSON or YAML files to build a collection of classes.'
  s.license     = 'Apache-2.0'
  s.add_development_dependency "rspec", "~> 2.6"
end