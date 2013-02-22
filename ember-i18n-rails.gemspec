# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ember/i18n/version"

Gem::Specification.new do |s|
  s.name        = "ember-i18n-rails"
  s.version     = Ember::I18n::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira", "Andrzej Sliwa"]
  s.email       = ["andrzej.sliwa@i-tool.eu"]
  s.homepage    = "http://rubygems.org/gems/ember-i18n-rails"
  s.summary     = ""
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "i18n"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "activesupport", ">= 3.0.0"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
end
