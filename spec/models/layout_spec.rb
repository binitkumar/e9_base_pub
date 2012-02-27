require 'spec_helper'
require 'declarative_authorization/maintenance'

describe Layout do
  include Authorization::TestHelper

  before(:each) do
    @region_types = 3.times.map { Factory(:region_type) }
    @layout = Factory(:layout, :region_types => @region_types).init!
    @layout.init!
    @layout.should be_valid
    @layout.should have(3).regions
  end
  describe "having regions" do
    it "should destroy its regions when destroyed" do
      without_access_control { Layout.destroy_all }
      Region.count.should be 0
    end
  end
  describe "when prototyping" do
    it "should generate the appropriate class" do
      @layout.prototype(SystemPage, :title => "Some Title", :identifier => "asdfasdf").class.should == SystemPage
      @layout.prototype(UserPage, :title => "Some Title").class.should == UserPage
    end
    it "should not save when called with no bang" do
      num = SystemPage.count
      @layout.prototype(SystemPage, :title => "Some Title", :identifier => "asdfasdf").class.should == SystemPage
      SystemPage.count.should == num
    end
    it "should save when called with a bang" do
      num = SystemPage.count
      @layout.prototype!(SystemPage, :title => "Some Title", :identifier => "asdfasdf")
      SystemPage.count.should == num + 1
    end
  end
end
