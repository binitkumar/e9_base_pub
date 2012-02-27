require 'spec_helper'

describe BlogPostsController do
  before do
    @blog  = Factory(:blog)
    @eblog = Factory(:blog, :role => 'employee', :slug => 'employee')
    LinkableSystemPage.create(:title => "Blog Index", :identifier => Page::Identifiers::BLOG_INDEX, :permalink => 'blog', :editable_content => false)

    1.times { Factory(:blog_post, :blog => @blog) }
    1.times { Factory(:blog_post, :blog => @eblog) }
    2.times { Factory(:published_blog_post, :blog => @blog) }
    2.times { Factory(:published_blog_post, :blog => @eblog) }
  end

  describe 'as user' do
    before(:each) do
      @user = Factory.create(:user)
      request.env['warden'] = mock_warden(@user)
    end
    describe "GET index" do
      before { get :index }
      it { response.should be_success }
      it { assigns(:blog_posts).length.should == 2 }
      it { assigns(:blog_posts).each {|p| p.should be_published } }
      it { assigns(:blog_posts).each {|p| p.blog.should == @blog } }
    end
    describe "GET index of EMPLOYEE blog" do
      before { get :index, :blog_id => 'employee' }
      it { flash[:alert].should_not be_nil }
      it { response.should be_redirect }
    end
    describe "GET index while paginating" do
      before do 
        get :index, :per_page => 1
      end
      it { assigns(:blog_posts).length.should == 1 }
    end
  end
  describe 'as employee' do
    before(:each) do
      @user = Factory.create(:user_employee)
      request.env['warden'] = mock_warden(@user)
    end
    describe "GET index" do
      before { get :index }
      it { response.should be_success }
      it { assigns(:blog_posts).length.should == 4 }
    end
    describe "GET index of EMPLOYEE blog" do
      before { get :index, :blog_id => 'employee' }

      it { response.should be_success }
      it { assigns(:blog_posts).length.should == @eblog.blog_posts.published.count }
      it { assigns(:blog_posts).each {|p| p.should be_published } }
      it { assigns(:blog_posts).each {|p| p.blog.should == @eblog } }
    end
  end

end
