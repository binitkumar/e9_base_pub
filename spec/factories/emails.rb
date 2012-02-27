Factory.sequence :email_subject do |n|
  "this is some email subject #{n}"
end

Factory.define :email do |t|
  t.association :author, :factory => :user
  t.subject { Factory.next(:email_subject) }
  t.name {|x| x.subject }
  t.html_body "<h1>HTML body</h1>"
  t.text_body "text body"
  t.from_email "from@email.com"
  t.reply_email "reply@email.com"
end

