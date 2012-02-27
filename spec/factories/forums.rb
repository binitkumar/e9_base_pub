Factory.sequence :forum_title do |n|
  "Forum #{n}"
end

Factory.define :forum do |f|
  f.title { Factory.next(:forum_title) }
end
