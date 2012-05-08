# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "e9_base/version"

Gem::Specification.new do |s|
  s.name          = "e9_base"
  s.version       = E9Base::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Travis Cox"]
  s.email         = ["travis@e9digital.com"]
  s.summary       = "e9digital Rails 3 CMS"
  s.description   = File.open('README.markdown').read rescue nil

  s.require_paths = ["lib"]

  s.files = Dir.glob("{script,engines,db,app,lib,config}/**/*") + %w(
    .gitignore
    Gemfile
    README.markdown
    Rakefile
    VERSION
  )

  s.add_dependency('rails', '3.0.10')
  s.add_dependency('devise', '~> 1.1.5')
  s.add_dependency('devise_revokable')
  s.add_dependency('declarative_authorization', '~> 0.5.1')
  s.add_dependency("inherited_resources", '1.2.2')
  s.add_dependency('responders', '0.6.4')
  s.add_dependency('has_scope', '0.5.0')
  s.add_dependency('haml', '3.1.2')
  s.add_dependency('sass', '3.1.2')
  s.add_dependency('compass', '0.11.4')
  s.add_dependency('compass-rgbapng', '0.1.1')
  s.add_dependency('rb-inotify', '0.8.5')
  s.add_dependency('will_paginate', '3.0.2')
  s.add_dependency('carrierwave', '0.5.7')
  s.add_dependency('mini_magick', '3.3')
  s.add_dependency('rack-cache', '1.2.0')
  s.add_dependency('rack-contrib', '1.1.0')
  s.add_dependency('uuidtools', '2.1.2')
  s.add_dependency('liquid', '2.2.2')
  s.add_dependency('acts_as_list', '0.1.3')
  s.add_dependency('breadcrumbs_on_rails', '1.0.1')
  s.add_dependency('chronic', '0.5.0')
  s.add_dependency('awesome_nested_set', '2.0.2')
  s.add_dependency('no_peeping_toms')
  s.add_dependency('delayed_job', '~> 2.1.2')
  s.add_dependency('fb_graph', '1.9.2')
  s.add_dependency('oauth2', '0.5.1')
  s.add_dependency('oauth', '0.4.5')
  s.add_dependency('twitter_oauth', '0.4.3')
  s.add_dependency('bitly', '0.6.1')
  s.add_dependency('jammit', '0.6.3')
  s.add_dependency("kramdown", "~> 0.13")
  s.add_dependency("draper", "0.9.5")
  s.add_dependency("rack-recaptcha", "0.6.3")
  s.add_dependency("rest-client", "~> 1.6.7")
  s.add_dependency("activemerchant", "1.20.0")
  s.add_dependency("dragonfly", "0.9.10")

  #s.add_dependency('e9_attributes', E9Base::VERSION)
  #s.add_dependency('e9_crm',        E9Base::VERSION)
  #s.add_dependency('e9_polls',      E9Base::VERSION)
  #s.add_dependency('e9_tags',       E9Base::VERSION)
  #s.add_dependency('e9_vendors',    E9Base::VERSION)

  s.add_development_dependency("mysql2", "< 0.3.0")
end
