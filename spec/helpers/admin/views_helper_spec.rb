require 'spec_helper'

describe Admin::ViewsHelper do
  before do
    helper.stub!(:current_user).and_return(@user = Factory(:user_administrator))
  end

  describe "renderables_for_region" do
    before do
      @region_type = Factory(:region_type)
      @renderables = [
        Factory(:snippet, :name => "bbb", :region_types => [@region_type], :role => @user.role),
        Factory(:snippet, :name => "aaa", :region_types => [@region_type], :role => @user.role),
        Factory(:snippet, :name => "xxx", :role => @user.role),
        Factory(:snippet, :name => "nnn", :region_types => [@region_type], :role => E9::Roles.top),
        Factory(:snippet, :name => "ccc", :region_types => [@region_type], :role => @user.role)
      ]
      @region = Factory(:region, :region_type => @region_type)
      @results = helper.renderables_for_region(@region)
    end

    it "should not include renderables with a role > current_user role, or those that do not include the region type" do
      @results.length.should be 3
    end

    it "should sort renderables alphabetically" do
      @results.should == @results.sort_by(&:name)
    end
  end
end
