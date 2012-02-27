require 'spec_helper'

describe BlogPost do
  before { @blog_post = Factory(:blog_post) }
  it { @blog_post.should be_valid }

  describe "slugs!" do
    it "should produce nice happy permalink slug from the title" do
      @nasty = "NASTY slug with invalid chars ;*(), spaces_AND_CAPS!"
      @nice  = "nasty-slug-with-invalid-chars-spaces_and_caps"
      Factory(:blog_post, :title => @nasty).permalink.should == @nice
    end
  end

  context "default preferences" do
    before { @user_page = Factory.build(:user_page) }
    it "should be sane" do
      E9::Config[:blog_show_social_bookmarks].should_not be_nil
    end
    it { @blog_post.display_social_bookmarks.should == E9::Config[:blog_show_social_bookmarks] }
    it { @blog_post.display_date.should             == E9::Config[:blog_show_date] }
    it { @blog_post.display_author_info.should      == E9::Config[:blog_show_author_info] }
    it { @blog_post.display_labels.should           == E9::Config[:blog_show_labels] }
    it { @blog_post.allow_comments.should           == E9::Config[:blog_allow_comments] }

  end
end
