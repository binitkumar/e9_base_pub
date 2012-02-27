require 'spec_helper'

describe Admin::UserPagesController do
  before do
    @user = Factory(:user_administrator)
    request.env['warden'] = mock_warden(@user)
  end
  
  context "GET show" do
    before { @user_page = Factory(:user_page) }
    #it("should 404") do
      #lambda { get :show, :id => @user_page.id }.should raise_error(ActionController::RoutingError)
    #end
  end

  context "GET edit" do
    before do 
      @user_page = Factory.create(:user_page)
      get :edit, :id => @user_page.permalink
    end
    it { response.should be_success }
  end

  context "GET change_layout" do

  end


  #describe "GET index" do
    #before(:each) do
      #@user = Factory(:user_administrator)
      #request.env['warden'] = mock_warden(@user)

      ## the default scope should be user pages base "Pages" aren't used typically
      #6.times { Factory.create(:user_page) }
    #end
    #before { get :index }
    #it { response.should be_success }
    #it { assigns(:pages).length.should == E9::Config[:admin_records_per_page] }
  #end

  #describe "GET index ordered" do
    #describe "desc" do
      #before { get :index, :ordered_on => 'title', :dir => 'desc' }
      #it { assigns(:pages).first.should == Page.order("title desc").first  }
    #end
    #describe "asc" do
      #before { get :index, :ordered_on => 'title', :dir => 'asc' }
      #it { assigns(:pages).first.should == Page.order("title asc").first }
    #end
  #end

end
