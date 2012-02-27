require 'spec_helper'

describe Admin::SearchesController do
  before do
    @user = Factory(:user_administrator)
    request.env['warden'] = mock_warden(@user)
    ('a'..'e').to_a.reverse.map.each {|l| Factory.create(:search, :query => l) }
  end

  it("should 404 on get show") do
    lambda { get :show }.should raise_error(ActionController::RoutingError)
  end

  describe "GET index" do
    before { get :index }
    it { response.should be_success }
    it "should be paginated" do 
      assigns(:searches).length.should == E9::Config[:admin_records_per_page]
    end
  end

  describe "GET index ordered" do
    describe "desc" do
      before { get :index, :ordered_on => 'query', :dir => 'desc' }
      it { assigns(:searches).first.query.should == 'e' }
    end
    describe "asc" do
      before { get :index, :ordered_on => 'query', :dir => 'asc' }
      it { assigns(:searches).first.query.should == 'a' }
    end
  end

end
