require 'spec_helper'

describe Settings do
  before { @settings = Factory(:settings) }

  it "should should refresh updated_at on save, even if object is unchanged" do
    proc { @settings.save }.should change(@settings, :updated_at)
  end

  context "class defaults" do
    before do
      @site_name = "SITE_NAME"
      Settings.default_attribute_values[:site_name] = @site_name
      @settings = Settings.create(:name => "HOOOOOO!")
    end

    it { Settings.fetch_attribute_default(:site_name).should == @site_name }

    context "defaulting" do
      before do
        Settings.default_attribute_values[:site_name].should == @site_name
      end

      it { @settings.site_name.should == @site_name }
      it { @settings.send(:site_name).should == @site_name }
      it { @settings.read_attribute(:site_name).should == @site_name }
      it { @settings.read_attribute_before_type_cast(:site_name).should == @site_name }
      it { @settings.read_attribute_for_validation(:site_name).should == @site_name }

      it "should revert to default and pass validation if nullified" do
        @settings.site_name = nil
        lambda { @settings.save }.should_not raise_error
      end

      it "should revert to default after being nullified" do
        @settings.site_name = nil
        #@settings.site_name.should == @site_name
        @settings.save!
        @settings.reload.site_name.should == @site_name
      end

      it "should revert to default and pass validation if set to empty string" do
        @settings.site_name = ""
        lambda { @settings.save }.should_not raise_error
      end

      it "should revert to default after being passed an empty string" do
        @settings.site_name = ""
        #@settings.site_name.should == @site_name
        @settings.save!
        @settings.reload.site_name.should == @site_name
      end
    end
  end
end
