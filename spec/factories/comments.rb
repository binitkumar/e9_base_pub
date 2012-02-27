# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :comment do |f|
  f.body "some comment body"
  f.association :author, :factory => :user
end
