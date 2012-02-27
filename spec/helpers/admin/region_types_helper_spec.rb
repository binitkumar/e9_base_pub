require 'spec_helper'

describe Admin::RegionTypesHelper do
  before do
    # TODO stubbing i18n kind of defeats the purpose in helper specs
    helper.stub!(:e9_t).and_return("some text")
  end

  describe "region_types_addable_to_renderable_by_user" do
    before do
      @region_types = [ Factory(:region_type, :name => "qwer", :role => 'administrator'),
                        Factory(:region_type, :name => "asdf", :role => 'administrator'),
                        Factory(:region_type, :name => "xcvx", :role => 'administrator'),
                        Factory(:region_type, :name => "onjf", :role => 'administrator')]

      @renderable   = Factory(:snippet, :region_types => [ @region_types.first ])
      @user         = Factory(:user_administrator)
      @results      = helper.region_types_addable_to_renderable_by_user(@renderable, @user)
    end
    it "should not return the region_type already attached" do
      @results.length.should == 3
    end
    it "should sort alphabetical by name" do
      @results.should == @results.sort_by(&:name)
    end
  end

  describe "region_type_select_array_for_renderable_and_user" do
    before do
      @renderable   = Factory(:snippet)
      @user         = Factory(:user_administrator)
    end
    it { lambda { helper.region_type_select_array_for_renderable_and_user(@renderable, @user) }.should_not raise_exception }
  end
end
