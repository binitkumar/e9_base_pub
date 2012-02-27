require 'spec_helper'

describe Admin::MenusHelper do
  before do
    helper.stub!(:current_user).and_return(@user = Factory(:user_administrator))
  end

  describe "links_for_current_user_and_menu" do
    before do 
      @count = 3
      @pages = @count.times.map { Factory(:user_page) }
      @menus = @pages.map {|page| @parent = Factory(:soft_link, :link => page.link, :parent => @parent) }
      @menus.each(&:reload)
      @used_links = @menus.map(&:link)

      @other_pages = @count.times.map { Factory(:user_page) }
      @other_pages.map(&:reload)
      @other_links = @other_pages.map(&:link)
      
      @menu = Factory.build(:soft_link, :parent => @parent, :link => nil)
      @links = helper.links_for_current_user_and_menu(@menu)
    end

    it "should be sane" do
      @menu.parent.should == @parent
      Link.all.should_not include(@menu)
      Link.count.should == @count * 2
    end

    it "should contain links" do
      @links.each {|link| link.should be_a_kind_of(Link) }
    end

    it "should contain the count of menus in the parent's tree" do
      @links.length.should == @count
    end
    
    it "should NOT contain menus that are in the passed menu's parent's tree" do
      (@links & @used_links).should be_empty
    end

    it "should contain menus unassociated to the passed menu's parent" do
      (@links - @other_links).should be_empty
    end
  end
end
