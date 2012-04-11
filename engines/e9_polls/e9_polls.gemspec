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
  s.require_paths = ["lib"]

  s.files = Dir.glob("{app,lib,config}/**/*") + %w(Gemfile Rakefile README.rdoc)
end
