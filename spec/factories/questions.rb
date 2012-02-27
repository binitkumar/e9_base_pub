# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.sequence :question_title do |n|
  "This is a FAQ Question (#{n})"
end

Factory.define :question do |f|
  f.title { Factory.next(:question_title) }
  f.association :faq
  f.answer "<p>This is a <b>faq answer</b></p>"
end
