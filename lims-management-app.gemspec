# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lims-management-app/version"

Gem::Specification.new do |s|
  s.name = "lims-management-app"
  s.version = Lims::ManagementApp::VERSION
  s.authors = ["Loic Le Henaff"]
  s.email = ["llh1@sanger.ac.uk"]
  s.homepage = "http://sanger.ac.uk/"
  s.summary = %q{Application supporting the LIMS functionality}
  s.description = %q{Lims samples and studies management}

  s.rubyforge_project = "lims-management-app"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('json')
  s.add_dependency('bunny', '0.9.0.pre4')

  s.add_development_dependency('rake', '~> 0.9.2')
  s.add_development_dependency('rspec', '~> 2.8.0')
  s.add_development_dependency('hashdiff')
  s.add_development_dependency('rack-test', '~> 0.6.1')
  s.add_development_dependency('yard', '>= 0.7.0')
  s.add_development_dependency('yard-rspec', '0.1')
  s.add_development_dependency('github-markup', '~> 0.7.1')
  s.add_development_dependency('rest-client')
end
