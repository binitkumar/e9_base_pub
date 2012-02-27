require 'spec_helper'

describe Menu do
  context "editing" do
    context "when #editable is false" do
      before { @menu = Factory(:menu, :editable => false) }
      context "for omnipotent users" do
        before { @user = Factory(:user_e9) }
        it "should be editable" do
          Menu.editable_for_user(@user).should include(@menu)
        end
      end
      context "for non-omnipotent users" do
        before { @user = Factory(:user_administrator) }
        it "should not be editable" do
          Menu.editable_for_user(@user).should_not include(@menu)
        end
      end
    end

    context "when #editable is true" do
      before { @menu = Factory(:menu, :editable => true) }
      context "for non-omnipotent users" do
        before { @user = Factory(:user_administrator) }
        it "should be editable" do
          Menu.editable_for_user(@user).should include(@menu)
        end
      end
    end
  end

  context "with hierarchy" do
    before do
      @menu  = nil
      @menus = 3.times.map { @menu = Factory(:soft_link, :parent => @menu) }
      @menus.each(&:reload)
    end

    it "should not be destroyable with children" do
      lambda{ @menus.first.destroy }.should raise_error(ActiveRecord::DeleteRestrictionError)
      lambda{ Menu.find(@menus.first.id) }.should_not raise_error
    end

    it "should be destroyable if leaf" do
      lambda{ @menus.last.destroy }.should_not raise_error(ActiveRecord::DeleteRestrictionError)
      lambda{ Menu.find(@menus.last.id) }.should raise_error
    end

    it "should be the menu I expect" do
      # this is a sanity check basically
      @menu.should be @menus.last
    end

    it "should show 3 links in linkables_in_hierarchy" do
      @menu.links_in_hierarchy.count.should == 3
    end

    it "should show 3 linkables in linkables_in_hierarchy" do
      @menu.linkables_in_hierarchy.count.should == 3
    end

    it "should match its root's descendants links in links_in_hierarchy" do
      @menu.links_in_hierarchy.sort_by(&:id).should == @menus.first.self_and_descendants.map(&:link).sort_by(&:id)
    end

    it "should match its root's descendants linkables in linkables_in_hierarchy" do
      @menu.linkables_in_hierarchy.sort_by(&:id).should == @menus.first.self_and_descendants.map(&:linkable).sort_by(&:id)
    end
  end
end
