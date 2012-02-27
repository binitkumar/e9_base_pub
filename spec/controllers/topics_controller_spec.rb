require 'spec_helper'

describe TopicsController do
  before do
    @forums_page = mock('forums_page').tap {|page| page.stub!(:title).and_return('Forums Page Title') }
    controller.stub!(:find_current_page).and_return(@forums_page)
  end

  describe "as user" do
    before { @user = Factory(:user); request.env['warden'] = mock_warden(@user) }
    describe "GET show" do
      before do
        @topic = Factory(:topic)
        get :show, :id => @topic.id
      end
      it { response.should be_success }
      it { assigns(:topic).should == @topic }
    end
    describe "POST create" do
      before do
        @forum = Factory(:forum)
        @topic = Factory.attributes_for(:topic, :forum_id => @forum.to_param)
      end
      it { @topic[:forum_id].should == @forum.to_param }

      describe "valid" do
        before { post :create, :topic => @topic }
        it { response.should redirect_to @forum }
        it { flash[:notice].should_not be_blank }
        it { flash[:alert].should == nil }
      end
      describe "with honeypot email" do
        before { post :create, :topic => @topic.merge(:email => "someval") }
        it { response.should redirect_to forums_path }
        it("should show a success message") { flash[:notice].should_not be_empty }
      end
    end
    describe "GET new" do
      describe "basic" do
        before { get :new }

        it { assigns(:topic).user_id.should == @user.id }
        it { assigns(:topic).forum_id.should be_nil }
      end
      describe "with a forum" do
        before do
          @forum = Factory(:forum)
          get :new, :forum_id => @forum.id
        end
        it { response.should be_success }
        it { @forum.id.should_not be_nil }
        it { controller.params[:forum_id].should == @forum.id }
        it { assigns(:forum).should == @forum }
        it { assigns(:topic).forum_id.should == @forum.id }
        it { assigns(:topic).user_id.should == @user.id }
      end
    end
    describe "GET edit" do
      before do
        @topic = Factory(:topic)
        get :edit, :id => @topic.id
      end
      it { flash[:alert].should_not be_empty }
      it { response.should be_redirect }
    end
  end

  describe "as admin" do
    before { @admin = Factory(:user_administrator); request.env['warden'] = mock_warden(@admin) }
    describe "GET edit" do
      before do
        @topic = Factory(:topic)
        get :edit, :id => @topic.id
      end
      it { flash[:alert].should == nil }
      it { response.should be_success }
    end

    describe "DELETE destroy" do
      describe "when it has comments" do
        before do
          @forum = Factory(:forum)
          @topic = Factory(:topic, :forum => @forum)
          @comments = Array.new(3, Factory(:comment, :commentable => @topic))
          delete :destroy, :id => @topic.id
        end
        it { Comment.find_by_id(*@comments.map(&:id)).should be_nil }
        it { flash[:notice].should_not be_nil }
      end
      describe "when the only topic of its forum" do
        before do
          @forum = Factory(:forum)
          @topic = Factory(:topic, :forum => @forum)
          delete :destroy, :id => @topic.id
        end
        it("should redirect to base forum path") { response.should redirect_to(forums_path) }
        it { flash[:notice].should_not be_nil }
      end
      describe "when its forum has remaining topics" do
        before do
          @forum = Factory(:forum)
          @topic = Factory(:topic, :forum => @forum)
          @topic = Factory(:topic, :forum => @forum)
          delete :destroy, :id => @topic.id
        end
        it("should redirect to the forum") { response.should redirect_to(@forum) }
        it { flash[:notice].should_not be_nil }
      end
    end
  end
end
