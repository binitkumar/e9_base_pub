require 'spec_helper'

describe Admin::MailingListsController do

  before do
    @user = Factory(:user_administrator)
    request.env["warden"] = mock_warden(@user)
  end

  describe "GET index" do
    before do
      2.times { Factory(:mailing_list) }
      2.times { Factory(:mailing_list, :newsletter => true, :system => false) }
      2.times { Factory(:mailing_list, :newsletter => false, :system => true) }
      2.times { Factory(:mailing_list, :newsletter => true, :system => true) }
      get :index 
    end
    it { response.should be_success }
    it("should show only newsletters") do
      assigns(:mailing_lists).length.should == 6
      assigns(:mailing_lists).each {|m| m.should be_newsletter }
    end
  end

  describe "GET new" do
    before { get :new }
    it { response.should be_success }
    it { assigns(:mailing_list).should be_an_instance_of(MailingList) }
  end
  
  describe "POST create" do
    before do
      @attributes = Factory.attributes_for(:mailing_list)
      post :create, :mailing_list => @attributes
    end
    it { response.should redirect_to admin_mailing_lists_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "GET edit" do
    before do
      @mailing_list = Factory(:mailing_list)
      get :edit, :id => @mailing_list.id
    end
    it { response.should be_success }
    it { assigns(:mailing_list).should == @mailing_list }
  end

  describe "PUT update" do
    before do
      @mailing_list = Factory(:mailing_list)
      @attributes = Factory.attributes_for(:mailing_list)
      put :update, :id => @mailing_list.id, :mailing_list => @attributes
    end
    it { response.should redirect_to admin_mailing_lists_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "DELETE destroy" do
    context "when mailing_list has no subscriptions" do
      before do
        @mailing_list = Factory(:mailing_list)
        delete :destroy, :id => @mailing_list.id
      end
      it { response.should redirect_to admin_mailing_lists_path }
      it { flash[:notice].should_not be_blank }
    end
    context "when mailing_list has subscriptions" do
      before do
        @mailing_list = Factory(:mailing_list)
        @subscriber   = Factory(:user)
        @subscription = Factory(:subscription, :user => @subscriber, :mailing_list => @mailing_list)
        delete :destroy, :id => @mailing_list.id
      end
      it { response.should redirect_to admin_mailing_lists_path }
      it { flash[:alert].should_not be_blank }
      it { assigns(:mailing_list).errors[:subscriptions].should_not be_blank }
    end
  end

end
