# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gdocs_reporting/version"

Gem::Specification.new do |s|
  s.name        = "gdocs_reporting"
  s.version     = GdocsReporting::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Noah Paessel"]
  s.email       = ["knowuh@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{proof of concept gem for reporting to a goold spreadsheet}
  s.description = %q{proof of concept gem for reporting to a goold spreadsheet}

  s.rubyforge_project = "gdocs_reporting"
  s.add_dependency('highline')
  s.add_dependency('bundler')
  s.add_dependency('rake')
  s.add_dependency('google-spreadsheet-ruby')
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
