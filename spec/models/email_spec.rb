require 'spec_helper'

module ActionMailerHelper
  def deliveries
    ActionMailer::Base.deliveries
  end
end

describe Email do
  include ActionMailerHelper

  before do 
    @email = Factory(:email)
    deliveries.clear
  end

  describe 'setting a recipient' do
    before { @email.recipient = @user = Factory(:user) }
    it { @email.recipient.should be @user }
    it { @email.locals['recipient'].should == @user}
    it { @email.locals['recipient'].username.should == @user.username}
    it { @email.locals['recipient'].email.should == @user.email }

    describe 'and overriding options' do
      before { @email.override_options!(:sender => @user) }

      it { @email.locals['sender'].should == @user}

      it 'should not override options not passed' do
        @email.locals['recipient'].should == @user
      end
    end
  end

  describe 'send!' do
    describe 'to a user' do
      before do 
        @mail = @email.send!(@user = Factory(:user))
      end
      it { @mail.should be_an_instance_of(Mail::Message) }
      it { @mail.to.should == [@user.email] }
      it 'should queue the mail for delivery' do
        deliveries.should_not be_empty
      end
    end
    context "to a list" do
      before do
        @subscribers  = 2.times.map { Factory(:user) }
        @subscribers << Factory(:user_administrator)

        @mailing_list = Factory(:mailing_list, :subscribers => @subscribers)
      end
      context "explicitly" do
        before do
          @email.send!(@mailing_list)
        end
        it { deliveries.length.should == 3 }
      end
      context "implicitly" do
        before do
          @email.mailing_list = @mailing_list
          @email.save && @email.reload
        end
        context "with specified recipients" do
          before do
            @recipients = [@subscribers.first]
            @recipients << @unsubscribed_user = Factory(:user)

            @email.send!(:recipients => @recipients)
          end
          it { deliveries.length.should == 1 }
          it { deliveries.first.to.should == [@subscribers.first.email] }
        end
        context "without specified recipients" do
          before do
            @email.send!
          end
          it { deliveries.length.should == 3 }
        end
        context "with a roled page" do
          before do
            @page = Factory(:user_page, :role => "administrator")
            @email.send!(:page => @page)
          end
          it { deliveries.length.should == 1 }
        end
        context "with a guest page" do
          before do
            @page = Factory(:user_page, :role => "guest")
            @email.send!(:page => @page)
          end
          it { deliveries.length.should == 3 }
        end
      end
    end
  end
end
