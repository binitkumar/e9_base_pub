require 'spec_helper'

describe Admin::ShareSitesController do
  before do
    @user = Factory(:user_administrator)
    request.env["warden"] = mock_warden(@user)
  end

  describe "GET index" do
    before do
      3.times { Factory(:share_site) }
      get :index 
    end
    it { response.should be_success }
    it { assigns(:share_sites).length.should == 3 }
    it { assigns(:share_sites).should == ShareSite.order(:position).all }
  end

  describe "GET new" do
    before { get :new }
    it { response.should be_success }
    it { assigns(:share_site).should be_an_instance_of(ShareSite) }
  end
  
  describe "POST create" do
    before do
      @attributes = Factory.attributes_for(:share_site)
      post :create, :share_site => @attributes
    end
    it { response.should redirect_to admin_share_sites_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "GET edit" do
    before do
      @share_site = Factory(:share_site)
      get :edit, :id => @share_site.id
    end
    it { response.should be_success }
    it { assigns(:share_site).should == @share_site }
  end

  describe "PUT update" do
    before do
      @share_site = Factory(:share_site)
      @attributes = Factory.attributes_for(:share_site)
      put :update, :id => @share_site.id, :share_site => @attributes
    end
    it { response.should redirect_to admin_share_sites_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "DELETE destroy" do
    before { @share_site = Factory(:share_site) }
    context "html" do
      before do
        delete :destroy, :id => @share_site.id
      end
      it { response.should redirect_to admin_share_sites_path }
      it { flash[:notice].should_not be_blank }
    end
    context "js" do
      before do
        delete :destroy, :id => @share_site.id, :format => :js
      end
      it { response.should render_template(:destroy) }
      it { flash[:notice].should_not be_blank }
    end
  end

end
