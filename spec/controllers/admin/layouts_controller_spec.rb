require 'spec_helper'

describe Admin::LayoutsController do
  before do
    @user = Factory(:user_administrator)
    request.env['warden'] = mock_warden(@user)
  end

  describe "GET index" do
    before do
      3.times { Factory(:layout) }
      get :index 
    end
    it { response.should be_success }
    it { assigns(:layouts).length.should == 3 }
    it { assigns(:layouts).should == Layout.all }
  end

  describe "GET edit" do
    before do
      @layout = Factory(:layout)
      get :edit, :id => @layout.id
    end
    it { response.should be_success }
    it { assigns(:layout).should == @layout }
  end

  describe "PUT update" do
    before do
      @layout = Factory(:layout)
      @attributes = Factory.attributes_for(:layout)
      put :update, :id => @layout.id, :layout => @attributes
    end
    it { response.should redirect_to admin_layouts_path }
    it { flash[:notice].should_not be_blank }
  end

end
