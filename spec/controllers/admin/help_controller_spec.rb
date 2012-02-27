require 'spec_helper'

describe Admin::HelpController do
  before do
    @user = Factory(:user_administrator)
    request.env['warden'] = mock_warden(@user)

    @layout = Layout.create(
      :name     => 'Admin',
      :template => 'admin',
      :identifier => Layout::Identifiers::ADMINISTRATOR
    )
    @system_page = @layout.prototype!(SystemPage, :identifier => Page::Identifiers::ADMIN_HELP, :title => "Admin Help")
  end

  describe "GET show" do
    before { get :show }
    it { response.should be_success }
    it { assigns(:current_page).should == @system_page }
  end

end
