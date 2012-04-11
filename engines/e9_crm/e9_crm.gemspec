# -*- encoding: utf-8 -*-
version = File.read(File.expand_path("../../../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = "e9_crm"
  s.version     = version
  s.platform    = Gem::Platform::RUBY
  s.email       = "travis@e9digital.com"
  s.homepage    = "http://www.e9digital.com"
  s.summary     = "CRM engine plugin for the e9 CMS"
  s.description = File.open('README.md').read rescue nil
  s.authors     = ['Travis Cox']

  s.rubyforge_project = "e9_crm"

  s.require_paths = ["lib"]

  s.files = Dir.glob("{app,lib,config}/**/*") + %w(Gemfile Rakefile README.md)

  s.add_dependency("money")
  s.add_dependency("kramdown", "~> 0.13")
end
