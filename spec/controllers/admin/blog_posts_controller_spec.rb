require 'spec_helper'

describe Admin::BlogPostsController do
  before do
    @user = Factory(:user_administrator)
    request.env['warden'] = mock_warden(@user)
  end

  describe "GET new" do
    # TODO dummy up layout for this test
    #before { get :new }
    #it { response.should be_success }
  end

end
