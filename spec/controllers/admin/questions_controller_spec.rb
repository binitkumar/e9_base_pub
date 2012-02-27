require 'spec_helper'

describe Admin::QuestionsController do
  before do
    @user = Factory(:user_administrator)
    request.env["warden"] = mock_warden(@user)
    @faq = Factory(:faq)
    @faq_path = admin_faq_questions_path(@faq)
  end

  describe "GET index" do
    before do
      3.times { Factory(:question, :faq => @faq) }
      3.times { Factory(:question) }
      get :index, :faq_id => @faq.to_param
    end
    it { response.should be_success }
    it { assigns(:questions).length.should == 3 }
  end

  describe "GET new" do
    before { get :new, :faq_id => @faq.to_param }
    it { response.should be_success }
    it { assigns(:question).should be_an_instance_of(Question) }
  end
  
  describe "POST create" do
    before do
      @attributes = Factory.attributes_for(:question)
      @attributes.delete(:faq_id)
      post :create, :faq_id => @faq.to_param, :question => @attributes
    end
    it { response.should redirect_to @faq_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "GET edit" do
    before do
      @question = Factory(:question, :faq => @faq)
      get :edit, :faq_id => @faq.to_param, :id => @question.id
    end
    it { response.should be_success }
    it { assigns(:question).should == @question }
  end

  describe "PUT update" do
    before do
      @question = Factory(:question, :faq => @faq)
      @attributes = Factory.attributes_for(:question)
      put :update, :faq_id => @faq.id, :id => @question.to_param, :question => @attributes
    end
    it { response.should redirect_to @faq_path }
    it { flash[:notice].should_not be_blank }
  end

  describe "POST update_order" do
    before do
      @questions = []
      3.times { @questions << Factory(:question, :faq => @faq) }
      @ids = @questions.sort_by(&:position).map(&:id)
      @ids.reverse!
      post :update_order, :faq_id => @faq.to_param, :ids => @ids, :format => :js
    end
    it { flash[:notice].should_not be_blank }
    it { @faq.reload.questions.sort_by(&:position).map(&:id).should == @ids }
  end

  describe "DELETE destroy" do
    before do
      @question = Factory(:question, :faq => @faq)
      delete :destroy, :faq_id => @faq.to_param, :id => @question.id
    end
    it { response.should redirect_to @faq_path }
    it { flash[:notice].should_not be_blank }
  end
end
