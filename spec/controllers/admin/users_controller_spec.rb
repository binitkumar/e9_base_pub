require 'spec_helper'

describe Admin::UsersController do
  before do
    @user = Factory(:user_administrator)
    request.env["warden"] = mock_warden(@user)
  end
  describe "GET index" do
    before { get :index }
    it { response.should be_success }
  end
end
