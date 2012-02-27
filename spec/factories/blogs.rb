# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.sequence :slug do |n|
  "slug-#{n}"
end

Factory.define :blog do |f|
  f.title "BLOG!"
  f.slug { Factory.next(:slug) }
end
