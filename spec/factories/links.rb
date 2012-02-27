# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :link do |f|
  f.association :linkable, :factory => :user_page
end
