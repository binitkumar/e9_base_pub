require 'spec_helper'

describe Admin::BlogsController do
  before do
    @user = Factory(:user_administrator)
    request.env['warden'] = mock_warden(@user)
  end
  
  describe "GET index" do
    before do
      3.times { Factory(:blog) }
      get :index 
    end
    it { response.should be_success }
    it { assigns(:blogs).length.should == 3 }
    it { assigns(:blogs).should == Blog.all }
  end

  describe "GET new" do
    before { get :new }
    it { response.should be_success }
    it { assigns(:blog).should be_an_instance_of(Blog) }
  end
  
  describe "POST create" do
    before do
      @attributes = Factory.attributes_for(:blog)
      post :create, :blog => @attributes
    end
    it { response.should redirect_to admin_blogs_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "GET edit" do
    before do
      @blog = Factory(:blog)
      get :edit, :id => @blog.to_param
    end
    it { response.should be_success }
    it { assigns(:blog).should == @blog }
  end

  describe "PUT update" do
    before do
      @blog = Factory(:blog)
      @attributes = Factory.attributes_for(:blog)
      put :update, :id => @blog.to_param, :blog => @attributes
    end
    it { response.should redirect_to admin_blogs_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "DELETE destroy" do
    context "when blog has no posts" do
      before do
        @blog = Factory(:blog)
        delete :destroy, :id => @blog.to_param
      end
      it { response.should redirect_to admin_blogs_path }
      it { flash[:notice].should_not be_blank }
    end
  end


end



