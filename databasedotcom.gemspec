# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "databasedotcom/version"

Gem::Specification.new do |s|
  s.name        = "databasedotcom"
  s.version     = Databasedotcom::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Danny Burkes & Richard Zhao"]
  s.email       = ["pair@pivotallabs.com"]
  s.homepage    = ""
  s.summary     = %q{A ruby wrapper for the Force.com REST API}
  s.description = %q{A ruby wrapper for the Force.com REST API}

  s.rubyforge_project = "databasedotcom"

  s.files         = Dir['README.rdoc', 'MIT-LICENSE', 'lib/**/*']
  s.require_paths = ["lib"]
  s.add_dependency('multipart-post', '>=1.1.3')
  s.add_development_dependency('rspec', '2.5.0')
  s.add_development_dependency('webmock')
  s.add_development_dependency('rake', '0.8.6')
  s.add_development_dependency('ruby-debug19')
end
