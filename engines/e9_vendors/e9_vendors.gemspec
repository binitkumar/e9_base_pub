# -*- encoding: utf-8 -*-
version = File.read(File.expand_path("../../../VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = "e9_vendors"
  s.version     = version
  s.authors     = ["Travis Cox"]
  s.email       = ["numbers1311407@gmail.com"]
  s.homepage    = "http://github.com/e9digital/e9_vendors"
  s.summary     = %q{Vendor directory with widget}
  s.description = File.open('README.markdown').read rescue nil

  s.rubyforge_project = "e9_vendors"
  s.require_paths = ["lib"]

  s.files = Dir.glob("{app,lib,config}/**/*") + %w(Gemfile Rakefile README.markdown)
end
