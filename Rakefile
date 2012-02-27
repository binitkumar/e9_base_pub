# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rdoc/task'

include Rake::DSL

E9::Application.load_tasks

ENGINES = %w(
  e9_attributes 
  e9_crm 
  e9_polls
  e9_tags 
  e9_vendors 
)

desc 'Bump all versions to match version.rb'
task :update_versions do

  File.open("VERSION", "w") do |f|
    f.write E9Base::VERSION + "\n"
  end

  if (migrations = Dir["db/migrate/*.rb"]).any?
    path = "db/archive/v#{E9Base::VERSION}"
    FileUtils.mkdir(path) unless File.exists?(path)
    FileUtils.mv migrations, path
    FileUtils.rmdir "db/migrate"
  end

  constants = {
    "e9_attributes" => "E9Attributes",
    "e9_crm" => "E9Crm",
    "e9_polls" => "E9Polls",
    "e9_tags" => "E9Tags",
    "e9_vendors" => "E9Vendors"
  }

  version_file = File.read("lib/e9_base/version.rb")

  ENGINES.each do |engine|
    Dir["engines/#{engine}/lib/*/version.rb"].each do |file|
      File.open(file, "w") do |f|
        f.write version_file.gsub(/E9Base/, constants[engine])
      end
    end
  end

  puts "Updated all to #{E9Base::VERSION}"
end
