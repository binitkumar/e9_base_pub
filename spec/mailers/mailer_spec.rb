require 'spec_helper'

describe Mailer do
  before(:each) do
    @user = Factory(:user)
  end
  context 'when mailing' do
    before(:each) do
      @html_body = '<h1>basic HTML body</h1>'
      @text_body = 'basic text body'
      @subject   = 'basic subject'
      @email = Factory(:email, :subject => @subject, :html_body => @html_body, :text_body => @text_body)
      @email.recipient = @user
      @mailer = Mailer.rendered_mail(@email).deliver
    end
    it 'should queue for delivery' do
      ActionMailer::Base.deliveries.should_not be_empty
    end
    it 'should have the proper values' do
      @mailer.to.should == [@user.email]
      @mailer.subject.should == @subject
      @mailer.encoded.should match %r/#{@html_body}/
      @mailer.encoded.should match %r/#{@text_body}/
    end
    context 'with interpolations' do
      before(:each) do
        @html_body = '{{ recipient.username }}'
        @text_body = '{{ recipient.username }}'
        @subject   = '{{ recipient.username }}'
        @email = Factory(:email, :subject => @subject, :html_body => @html_body, :text_body => @text_body)
        @email.recipient = @user
      end
      context 'of default values' do
        before(:each) do
          @mailer = Mailer.rendered_mail(@email)
        end
        it 'should have the proper values' do
          @mailer.to.should == [@user.email]
          @mailer.subject.should == @user.username
          @mailer.encoded.should match %r/#{@user.username}/
          @mailer.encoded.should match %r/#{@user.username}/
        end
      end
      context 'of overridden values' do
        before(:each) do
          @not_username = "not the username!"
          @not_user = Factory(:user, :username => @not_username)
          @mailer = Mailer.rendered_mail(@email, :recipient => @not_user)
        end

        # Actually it's questionable that this should happen, as this
        # *does not* change the recipient, only the recipient passed in
        # the locals hash used for interpolating the email text
        it 'should have the proper values' do
          @mailer.to.should == [@user.email]
          @mailer.subject.should == @not_username
          @mailer.encoded.should match %r/#{@not_username}/
          @mailer.encoded.should match %r/#{@not_username}/
        end
      end
    end
  end
end
