require File.join(File.dirname(__FILE__), '../test_helper')

class UserMailerTest < ActionMailer::TestCase 
  def test_basic_email
    html_body = '<h1>basic HTML body</h1>'
    text_body = 'basic text body'
    subject   = 'basic subject'

    user           = Factory(:user)  
    email_template = Factory(:email, 
                             :subject => subject, 
                             :html_body => html_body,
                             :text_body => text_body)

    email = UserMailer.templated_email(email_template, user).deliver

    assert !ActionMailer::Base.deliveries.empty?  

    assert_equal [user.email], email.to 
    assert_equal subject, email.subject 
    assert_match %r/#{html_body}/, email.encoded  
    assert_match %r/#{text_body}/, email.encoded  
  end 

  def test_standard_interpolation
    html_body = '{{ username }}'
    text_body = '{{ username }}'
    subject   = '{{ username }}'

    user           = Factory(:user)  
    email_template = Factory(:email, 
                             :subject => subject, 
                             :html_body => html_body,
                             :text_body => text_body)

    email = UserMailer.templated_email(email_template, user)

    assert_equal email.subject, user.username
    assert_match %r/#{user.username}/, email.encoded  
    assert_match %r/#{user.username}/, email.encoded  
  end 

  def test_override_interpolation
    html_body = '{{ username }}'
    text_body = '{{ username }}'
    subject   = '{{ username }}'

    not_username = "asdfasdfasdf"

    user           = Factory(:user)  
    email_template = Factory(:email, 
                             :subject => subject, 
                             :html_body => html_body,
                             :text_body => text_body)

    email = UserMailer.templated_email(email_template, user, :username => not_username)

    assert_equal email.subject, not_username
    assert_match %r/#{not_username}/, email.encoded  
    assert_match %r/#{not_username}/, email.encoded  
  end
end 
