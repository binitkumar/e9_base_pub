# Load profile environment
env = ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

#ENV["RAILS_ENV"] = "test"

# Load Rails testing infrastructure
#require 'rails/test_help'

# Now we can load test_helper since we've already loaded the
# profile RAILS environment.
require File.expand_path(File.join(Rails.root, 'test', 'test_helper'))

# Reset the current environment back to profile
# since test_helper reset it to test
ENV["RAILS_ENV"] = env

# Now load ruby-prof and away we go
require 'ruby-prof/test'

# Setup output directory to Rails tmp directory
RubyProf::Test::PROFILE_OPTIONS[:output_dir] = File.expand_path(File.join(Rails.root, 'tmp', 'profile'))
