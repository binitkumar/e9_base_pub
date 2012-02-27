require 'spec_helper'

describe Admin::FaqsController do
  before do
    @user = Factory(:user_administrator)
    request.env["warden"] = mock_warden(@user)
  end

  describe "GET index" do
    before do
      3.times { Factory(:faq) }
      get :index 
    end
    it { response.should be_success }
    it { assigns(:faqs).length.should == 3 }
    it { assigns(:faqs).should == Faq.all }
  end

  describe "GET new" do
    before { get :new }
    it { response.should be_success }
    it { assigns(:faq).should be_an_instance_of(Faq) }
  end
  
  describe "POST create" do
    before do
      @attributes = Factory.attributes_for(:faq)
      post :create, :faq => @attributes
    end
    it { response.should redirect_to admin_faqs_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "GET edit" do
    before do
      @faq = Factory(:faq)
      get :edit, :id => @faq.id
    end
    it { response.should be_success }
    it { assigns(:faq).should == @faq }
  end

  describe "PUT update" do
    before do
      @faq = Factory(:faq)
      @attributes = Factory.attributes_for(:faq)
      put :update, :id => @faq.id, :faq => @attributes
    end
    it { response.should redirect_to admin_faqs_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "DELETE destroy" do
    context "when faq has no questions" do
      before do
        @faq = Factory(:faq)
        delete :destroy, :id => @faq.id
      end
      it { response.should redirect_to admin_faqs_path }
      it { flash[:notice].should_not be_blank }
    end
    context "when faq has questions" do
      before do
        @faq = Factory(:faq)
        @question = Factory(:question, :faq => @faq)
        delete :destroy, :id => @faq.id
      end
      it { response.should redirect_to admin_faqs_path }
      it { flash[:alert].should_not be_blank }
      it { assigns(:faq).errors[:questions].should_not be_blank }
    end
  end
end
