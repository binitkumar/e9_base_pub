#require File.dirname(__FILE__) + '/../profile_test_helper'
require File.expand_path('../../profile_test_helper', __FILE__)
require 'rails/performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BrowsingTest < ActionDispatch::PerformanceTest
  include RubyProf::Test

  def test_homepage
    get '/'
  end

  def test_basic_page
    get "/#{UserPage.first.permalink}"
  end
end
