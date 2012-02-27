# -*- encoding: utf-8 -*-
version = File.read(File.expand_path("../../../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = "e9_polls"
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Travis Cox"]
  s.email       = ["travis@e9digital.com"]
  s.homepage    = "http://github.com/e9digital/e9_polls"
  s.summary     = %q{Polls module for the e9 Rails 3 cms}
  s.description = File.open('README.rdoc').read rescue nil

  s.rubyforge_project = "e9_polls"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
