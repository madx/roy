# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "roy/version"

Gem::Specification.new do |s|
  s.name        = "roy"
  s.version     = Roy::VERSION
  s.authors     = ["madx"]
  s.email       = ["madx@yapok.org"]
  s.homepage    = "https://github.com/madx/roy"
  s.summary     = 'make your objects REST-friendly'
  s.description =
    "roy is a small library which allows every Ruby object to be used\n" <<
    "as a Rack application."

  s.rubyforge_project = "roy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "minitest"
  s.add_development_dependency "rack-test"
  # s.add_runtime_dependency "rest-client"
end
