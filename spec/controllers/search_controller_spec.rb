require 'spec_helper'

describe SearchController do
  before do
    @controller.stub!(:current_user).and_return(nil)
    @controller.stub!(:pagination_per_page_default).and_return(1)
  end

  context "GET index" do
    context "with no query" do
      before { get :index }
      it { response.should redirect_to :root }
    end
    context "with a query" do
      before { get :index, :query => 'asdf' }
      it { response.should be_success }
      it { assigns(:search).search_count.should == 1 }
    end
    context "with a duplicate query" do
      before do 
        @query = 'asdf'
        Factory(:search, :query => @query)
        get :index, :query => @query
      end
      it { response.should be_success }
      it { assigns(:search).search_count.should == 2 }
    end
  end

  context "GET show" do
    context "with no id" do
      before { get :show }
    end
    context "for a bogus id" do
      before { get :show, :id => 'asdf' }
    end
  end
end
