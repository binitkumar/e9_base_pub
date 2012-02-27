require 'spec_helper'

describe Admin::ForumsController do
  before do
    @user = Factory(:user_administrator)
    request.env["warden"] = mock_warden(@user)
  end

  describe "GET index" do
    before do
      3.times { Factory(:forum) }
      get :index 
    end
    it { response.should be_success }
    it { assigns(:forums).length.should == 3 }
    it { assigns(:forums).should == Forum.all }
  end

  describe "GET new" do
    before { get :new }
    it { response.should be_success }
    it { assigns(:forum).should be_an_instance_of(Forum) }
  end
  
  describe "POST create" do
    before do
      @attributes = Factory.attributes_for(:forum)
      post :create, :forum => @attributes
    end
    it { response.should redirect_to admin_forums_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "GET edit" do
    before do
      @forum = Factory(:forum)
      get :edit, :id => @forum.id
    end
    it { response.should be_success }
    it { assigns(:forum).should == @forum }
  end

  describe "PUT update" do
    before do
      @forum = Factory(:forum)
      @attributes = Factory.attributes_for(:forum)
      put :update, :id => @forum.id, :forum => @attributes
    end
    it { response.should redirect_to admin_forums_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "DELETE destroy" do
    context "when forum has no topics" do
      before do
        @forum = Factory(:forum)
        delete :destroy, :id => @forum.id
      end
      it { response.should redirect_to admin_forums_path }
      it { flash[:notice].should_not be_blank }
    end
  end
end
