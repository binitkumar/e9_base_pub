require 'spec_helper'

describe Admin::SnippetsController do
  before do
    @user = Factory(:user_administrator)
    request.env["warden"] = mock_warden(@user)
  end
  describe "GET index" do
    before { get :index }
    it { response.should be_success }
  end

  describe "POST create" do
    context "with valid params" do
      before do
        @params = Factory.attributes_for(:snippet)
        post :create, :snippet => @params
      end
      it { response.should redirect_to(admin_snippets_path) }
      it { flash[:notice].should_not be_blank }
    end
    context "without valid params" do
      before do
        post :create, :snippet => {}
      end
      #it { response.should render_template('new') }
      it { flash[:alert].should_not be_blank }
    end
  end

  describe "PUT update" do
    context "with valid params" do
      before do
        @snippet = Factory(:snippet)
        put :update, :id => @snippet.id, :snippet => @snippet.attributes
      end
      it { response.should redirect_to(admin_snippets_path) }
      it { flash[:notice].should_not be_blank }
    end
    context "without valid params" do
      before do
        @snippet = Factory(:snippet)
        put :update, :id => @snippet.id, :snippet => { :name => nil, :template => nil }
      end
      #it { response.should render_template('edit') }
      it { flash[:alert].should_not be_blank }
    end
  end
  
  describe "PUT revert" do
    before do 
      @params = { :template => "HELLO", :revert_template => "GOODBYE" }
      @snippet = Factory(:snippet, @params)
      put :revert, :id => @snippet.id
    end
    it { response.should redirect_to admin_snippets_path }
    it { @snippet.reload.template.should == @params[:revert_template] }
  end

  describe "Setting revert" do
    before do
      @params = Factory.attributes_for(:snippet)
      @snippet = Factory(:snippet)
      @params[:set_revert_template] = 'true'
      @params[:template] = "SOME TEXT"
    end
    describe "on update" do
      before { put :update, :id => @snippet.id, :snippet => @params, :set_revert_template => 'true' }
      it { @snippet.reload.revert_template.should == @params[:template] }
    end
  end

  describe "passing no region_types" do
    before do
      @region_types = Array.new(3, Factory(:region_type))
      @snippet = Factory(:snippet, :region_type_ids => @region_types.map(&:id))
    end
    it "should clear the region types if admin_form is true" do
      put :update, :id => @snippet.id, :admin_form => true, :snippet => { :template => "bananas" }
      @snippet.reload.region_type_ids.should == []
    end
    it "should NOT clear the region types if admin_form is not true" do
      put :update, :id => @snippet.id, :snippet => { :template => "bananas" }
      @snippet.reload.region_type_ids.should_not == []
    end
  end
end
