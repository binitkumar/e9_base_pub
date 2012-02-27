require 'spec_helper'

describe Snippet do
  context "revert template saving" do
    before { @template = "BANANAS!" }
    describe "should be set when set_revert_template is true" do
      before { @snippet = Factory(:snippet, :set_revert_template => true, :template => @template) }
      it { @snippet.revert_template.should == @template }
    end
    describe "should NOT be set when set_revert_template is false" do
      before { @snippet = Factory(:snippet, :set_revert_template => false, :template => @template) }
      it { @snippet.revert_template.should_not == @template }
    end
    describe "should NOT be set when set_revert_template is nil" do
      before { @snippet = Factory(:snippet, :template => @template) }
      it { @snippet.revert_template.should_not == @template }
    end
  end

  context "revert template reverting" do
    it "should fail with errors if revert template is blank" do
      @params = { :template => "ARRRRGGGHHH" }
      @snippet = Factory(:snippet, @params)
      @snippet.revert_template!
      @snippet.errors[:revert_template].should_not be_empty
      @snippet.template.should == @params[:template]
    end
    it "should succeed if revert_template is set" do
      @params = { :revert_template => "WOOOOOO!!!", :template => "ARRRRGGGHHH" }
      @snippet = Factory(:snippet, @params)
      @snippet.revert_template!
      @snippet.template.should == @params[:revert_template]
    end
  end

  context "when a member of a layout" do
    before do
      @region_type = Factory(:region_type)
      @layout = Factory(:layout, :region_types =>[@region_type]).reset!
      @snippet = Factory(:snippet, :region_types => [@region_type])
      @layout.regions.first.add_renderable!(@snippet)
      @snippet.reload
    end

    it { @snippet.should be_valid }

    context "removing the region_type of the snippet should not be possible if an including layout references the snippet under that region_type" do
      before { @snippet.region_type_ids = []; @snippet.valid? }
      #it { @snippet.should_not be_valid }
      #it { @snippet.errors[:region_type_ids].should_not be_blank }
    end
  end

  context "with nodes" do
    before do
      @nodes = Array.new(3, Factory(:node))
      @snippet = Factory(:snippet, :nodes => @nodes)
    end

    context "should not be destroyable" do
      before do
        begin
          @snippet.destroy
        rescue => @error
        end
      end
      it { @error.should be_an_instance_of(ActiveRecord::DeleteRestrictionError) }
      it { lambda{ Snippet.find(@snippet.id) }.should_not raise_error }
    end
  end
end
