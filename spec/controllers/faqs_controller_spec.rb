require 'spec_helper'

describe FaqsController do
  before do
    @faqs_page = mock('faqs_page').tap {|page| page.stub!(:title).and_return('Faqs Page Title') }
    controller.stub!(:find_current_page).and_return(@faqs_page)
  end

  before do
    @user = Factory(:user)
    request.env['warden'] = mock_warden(@user)
    5.times do 
      faq = Factory(:faq)
      faq.questions = [Factory(:question, :faq => faq)]
      faq.save
    end
  end

  describe 'GET index' do
    before { get :index }
    it { response.should be_success }
    it { assigns(:faqs).length.should == 5 }
    it { assigns(:faqs).should == Faq.questioned.ordered }
  end
end
