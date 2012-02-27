require 'spec_helper'

describe RegionType do
  describe "editable_by_user" do
    before do
      @region_types = [ Factory(:region_type, :name => "qwer", :role => 'administrator'),
                        Factory(:region_type, :name => "xxxx", :role => 'e9_user'),
                        Factory(:region_type, :name => "bbbb", :role => 'e9_user'),
                        Factory(:region_type, :name => "xcvx", :role => 'administrator'),
                        Factory(:region_type, :name => "xcvx", :role => 'user')]

      @user = Factory(:user_administrator)
    end
    it "should return region_types with roles <= the region_type's role " do
      RegionType.editable_by_user(@user).length.should == 3
    end
  end
end
