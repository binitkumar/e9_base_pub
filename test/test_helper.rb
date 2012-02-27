ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'declarative_authorization/maintenance'

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

require File.expand_path('../../db/seeds', __FILE__)

# Add support to load paths so we can overwrite broken webrat setup
#$:.unshift File.expand_path('../../spec/factories', __FILE__)
#Dir["#{File.dirname(__FILE__)}/../spec/factories/*.rb"].each { |f| require f }
#$:.shift

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
end
