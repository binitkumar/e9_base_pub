# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :search do |f|
  f.query "some query"
  f.association :user
end
