require 'rubygems'
require 'spork'

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'rspec/rails'

# Require all factories under spec/factories
Dir["#{File.dirname(__FILE__)}/factories/*.rb"].each {|f| require f}

# Requires supporting files with custom matchers and macros, etc in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ActiveRecord::Observer.disable_observers
end

Spork.each_run do
end

Rspec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #config.mock_with :rspec

  # If you'd prefer not to run each of your examples within a transaction,
  # uncomment the following line.
  #config.use_transactional_examples false

  config.before(:each) do
    SystemEmail.stub!(:friend_email).and_return(mock_system_email)
    SystemEmail.stub!(:reset_password).and_return(mock_system_email)
    SystemEmail.stub!(:new_content_alert).and_return(mock_system_email)
    SystemEmail.stub!(:comment_updates).and_return(mock_system_email)

    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

if defined?(ActiveRecord::Base)
  begin
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
  rescue LoadError => ignore_if_database_cleaner_not_present
  end
end

def mock_warden(user)
  mock('warden').tap do |warden|
    warden.stub!(:authenticate).with(:scope => :user).and_return(user)
    warden.stub!(:authenticate!).with(:scope => :user)
    warden.stub!(:authenticated?).with(:user).and_return(!!user)
    warden.stub!(:user).with(:user).and_return(user)
  end
end

def mock_system_email
  mock('system_email').tap do |s|
    s.stub!(:send!).and_return(true)
  end
end

class MockEmail
  attr_reader :recipients, :sender, :page
  def send!(opts)
    @page = opts[:page]
    @sender = opts[:sender]
    @recipients = opts[:recipients]
  end
end
