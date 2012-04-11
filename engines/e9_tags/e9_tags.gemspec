# -*- encoding: utf-8 -*-
version = File.read(File.expand_path("../../../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = "e9_tags"
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Travis Cox"]
  s.email       = ["travis@e9digital.com"]
  s.homepage    = "http://github.com/e9digital/e9_tags"
  s.summary     = %q{Extension to ActsAsTaggableOn used in e9 Rails 3 projects}
  s.description = File.open('README.rdoc').read rescue nil

  s.rubyforge_project = "e9_tags"
  s.require_paths = ["lib"]

  s.files = Dir.glob("{app,lib,config}/**/*") + %w(Gemfile Rakefile README.rdoc)

  s.add_dependency("rails", "~> 3.0.0")
  s.add_dependency("acts-as-taggable-on", "~> 2.0.6")
end
