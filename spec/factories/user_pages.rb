Factory.sequence :user_page_title do |n|
  "User Page Title #{n}"
end

Factory.define :user_page do |f|
  f.title { Factory.next(:user_page_title) }
  f.body "dummy body"
  f.author_string "some author"
  f.published_at DateTime.now
end

Factory.define :user_page_with_content, :parent => :user_page do |f|
  f.regions {|a| [a.association(:region_with_nodes), a.association(:region)] }
end
