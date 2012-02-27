# Read about factories at http://github.com/thoughtbot/factory_girl

# TODO would be nice if STI worked with factory girl
Factory.define :newsletter do |f|
  f.subject { Factory.next(:email_subject) }
  f.name {|g| g.subject }
  f.association :author, :factory => :user
  f.association :mailing_list
  f.html_body "<h1>HTML body</h1>"
  f.text_body "text body"
  f.delivery_date { Date.today + 1.week }
  f.from_email "from@email.com"
  f.reply_email "reply@email.com"
end

Factory.define :newsletter_with_subscribers, :parent => :newsletter do |f|
  f.association :mailing_list, :factory => :mailing_list_with_subscribers
end
