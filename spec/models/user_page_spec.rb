require 'spec_helper'

describe UserPage do
  before { @user_page = Factory(:user_page) }
  it { @user_page.should be_valid }

  describe "slugs!" do
    it "should produce nice happy permalink slug from the title" do
      @nasty = "NASTY slug with invalid chars ;*(), spaces_AND_CAPS!"
      @nice  = "nasty-slug-with-invalid-chars-spaces_and_caps"
      Factory(:blog_post, :title => @nasty).permalink.should == @nice
    end
  end

  context "concerning links" do
    context "with its link in a menu" do
      before do
        @menu = Factory(:soft_link, :link => @user_page.link)
        @user_page.reload
      end
      it { lambda{ @user_page.destroy }.should raise_error(ActiveRecord::DeleteRestrictionError) }
      it { lambda{ UserPage.find(@user_page.id) }.should_not raise_error }
    end

    context "with its link NOT in a menu" do
      it { lambda{ @user_page.destroy }.should_not raise_error(ActiveRecord::DeleteRestrictionError) }
      it { lambda{ UserPage.find(@page.id) }.should raise_error }
    end
  end

  context "concering comments" do
    before do
      @user = Factory(:user)
      @user_page.update_attribute(:role, 'administrator')
      @user_page.comments.create(:author => @user)
    end
    it "should set comment role on creation" do
      @user_page.reload.comments.each {|c| c.role.should == 'administrator' }
    end
    it "should update comments roles on role update" do
      @user_page.update_attribute(:role, 'user')
      @user_page.reload.comments.each {|c| c.role.should == 'user' }
    end
  end

  context "concering favorites" do
    before do
      @user = Factory(:user)
      @user_page.update_attribute(:role, 'administrator')
      @user_page.favorites.create(:user => @user)
    end
    it "should set favorite role on creation" do
      @user_page.reload.favorites.each {|f| f.role.should == 'administrator' }
    end
    it "should update favorites roles on role update" do
      @user_page.update_attribute(:role, 'user')
      @user_page.reload.favorites.each {|f| f.role.should == 'user' }
    end
  end

  context "default preferences" do
    before { @user_page = Factory(:user_page) }
    it { @user_page.display_social_bookmarks.should == E9::Config[:page_show_social_bookmarks] }
    it { @user_page.display_date.should             == E9::Config[:page_show_date] }
    it { @user_page.display_author_info.should      == E9::Config[:page_show_author_info] }
    it { @user_page.display_labels.should           == E9::Config[:page_show_labels] }
    it { @user_page.allow_comments.should           == E9::Config[:page_allow_comments] }
  end
end
