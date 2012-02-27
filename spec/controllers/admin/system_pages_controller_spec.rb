require 'spec_helper'

describe Admin::SystemPagesController do
  before do
    @user = Factory(:user_administrator)
    request.env['warden'] = mock_warden(@user)
  end
  describe 'GET index' do
    it { lambda { get :index }.should_not raise_error(ActionController::RoutingError) }
  end

end
