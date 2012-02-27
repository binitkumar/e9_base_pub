# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :system_email do |f|
end

Factory.define :friend_system_email, :parent => :system_email do |f|
  f.name "Email a friend"
  f.identifier SystemEmail::Identifiers::FRIEND_EMAIL
  f.subject "I just saw this on {% site_name %} - {% page_title %}"
  f.reply_email E9::Config[:site_email_address]
  f.from_email E9::Config[:site_email_address]
  f.html_body "blah {% email_message %} blah"
  f.text_body "blah {% email_message %} blah"
end
