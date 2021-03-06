# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "lemur"
  s.version     = "0.2.0"
  s.authors     = ["Clinton R. Nixon"]
  s.email       = ["crnixon@gmail.com"]
  s.homepage    = "http://github.com/crnixon/lemur-scheme"
  s.summary     = %q{A simple Scheme implemented in Ruby}
  s.description = %q{A simple Scheme implemented in Ruby. Has full Ruby access. No macros yet.}

  s.rubyforge_project = "lemur"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rparsec-ruby19"
  s.add_development_dependency "contest"
end
