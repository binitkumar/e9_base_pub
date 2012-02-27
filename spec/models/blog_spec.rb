require 'spec_helper'

describe Blog do
  before { @blog = Factory(:blog) }
  it { @blog.should be_valid }

  it "should be guest access if not specified" do
    Factory(:blog, :role => nil).role.should == E9::Roles.bottom
  end

  describe "having blog_posts" do
    before do
      2.times { Factory(:blog_post, :blog => @blog) }
      @blog.reload
    end

    it "should not be destroyable" do
      lambda{ @blog.destroy }.should raise_error(ActiveRecord::DeleteRestrictionError)
      lambda{ Blog.find(@blog.id) }.should_not raise_error
    end

    it "role update should update posts role" do
      @blog.blog_posts.each {|post| post.role.should == E9::Roles.bottom }

      @blog.role = 'employee'
      @blog.save && @blog.reload

      @blog.role.should == 'employee'
      @blog.blog_posts.each {|post| post.role.should == @blog.role }
    end
  end

end
