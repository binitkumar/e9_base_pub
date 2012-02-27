# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.sequence :topic_title do |n|
  "Topic #{n}"
end

Factory.define :topic do |f|
  f.title { Factory.next(:topic_title) } 
  f.association :author, :factory => :user
  f.association :forum
  f.body "topic body"
end
