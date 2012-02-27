# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :friend_email do |f|
  f.sender_email 'sender@example.com'
  f.recipient_email 'recipient@example.com'
  f.message 'some message'
  f.association :link, :factory => :user_page
end
