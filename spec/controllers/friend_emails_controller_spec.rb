require 'spec_helper'

describe FriendEmailsController do
  before do
    @user = Factory(:user)
    request.env['warden'] = mock_warden(@user)

    @linkable = Factory(:user_page)
    @link = @linkable.link
  end

  describe "GET new" do
    describe "without page params" do
      before { get :new }
      it { response.response_code.should == 404 }
    end
    describe "with page params" do
      before do
        get :new, :link_id => @link.id
      end
      it { response.should be_success }
      it { assigns(:friend_email).should be_an_instance_of(FriendEmail) }
      it { assigns(:friend_email).link.linkable.should == @linkable }
    end
  end

  describe "POST create" do
    before do
      SystemEmail.stub!(:friend_email).and_return(Factory.build(:friend_system_email))
    end

    describe "with valid params" do
      before do
        @page   = Factory(:user_page)
        @params = Factory.attributes_for(:friend_email).merge(:link_id => @page.link.id)
      end
      context "normally" do
        before { post :create, :friend_email => @params, :format => :js }
        it { response.status.should be 200 }
        it { assigns(:friend_email).should be_an_instance_of(FriendEmail) }
        it { flash[:notice].should_not be_empty }
      end

      describe "with honeypot email" do
        before { post :create, :friend_email => @params.merge(:email => "someval"), :format => :js }
        it { response.status.should be 200 }
        it { assigns(:friend_email).id.should be_nil }
        it("should show a success message") { flash[:notice].should_not be_empty }
      end
    end


    describe "with invalid params" do
      before do
        post :create, :friend_email => { :recipient_email => "asdfasdfasdfasdf" }, :format => :js
      end
      it { response.should_not be_redirect }
      it { assigns(:friend_email).should be_an_instance_of(FriendEmail) }
      it { assigns(:friend_email).errors.should_not be_empty }
      it { flash[:alert].should_not be_blank }
    end

  end
end
