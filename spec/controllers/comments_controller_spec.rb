require 'spec_helper'

describe CommentsController do
  before(:each) do
    @user = Factory.create(:user)
    request.env['warden'] = mock_warden(@user)
    2.times { @user.comments.create(:body => "asdfasdf", :commentable => Factory(:user_page)) }
    2.times { @user.comments.create(:body => "asdfasdf", :commentable => Factory(:topic)) }
  end
  describe "GET index" do
    describe "no args" do
      before { get :index, :format => :js }
      it { response.should be_success }
      it { assigns(:comments).each {|fav| fav.should be_an_instance_of(Comment) } }
    end
    describe "on_type pages" do
      before { get :index, :on_type => 'page', :format => :js}
      it { response.should be_success }
      it { assigns(:comments).each {|fav| fav.commentable.should be_an_instance_of(UserPage) } } 
    end
    describe "on_type topics" do
      before { get :index, :on_type => 'topic', :format => :js}
      it { response.should be_success }
      it { assigns(:comments).each {|fav| fav.commentable.should be_an_instance_of(Topic) } } 
    end
    describe "by_user" do
      before { get :index, :by_user => @user.id, :format => :js }
      it { response.should be_success }
      it { assigns(:comments).should =~ @user.comments }
    end
    describe "for a topic" do
      before { @topic = Topic.last; get :index, :topic_id => @topic.id, :format => :js }
      it { assigns(:topic).should == @topic }
      it { response.should be_success }
      it { assigns(:comments).should == @topic.comments }
    end
    describe "for a user page" do
      before { @page = UserPage.last; get :index, :page_id => @page.permalink, :format => :js }
      it { @page.should be_an_instance_of(UserPage) }
      it { response.should be_success }
      it { assigns(:page).should == @page }
      it { assigns(:comments).should == @page.comments }
    end
  end
  describe "for page" do
    before { @page = Factory(:user_page) }
    describe "POST create" do
      before { post :create, :page_id => @page.to_param, :comment => Factory.attributes_for(:comment), :format => :js }
      it { response.should be_success }
      it { assigns(:comment).author.should == @user }
    end
  end
  describe "DELETE destroy" do
    before { @comment = Factory(:comment); delete :destroy, :id => @comment.id, :format => :js }
    it { response.should be_success }
    it { assigns(:comment).should == @comment }
    it { assigns(:comment).deleted?.should be_true }
  end
end
