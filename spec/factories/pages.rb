Factory.sequence :page_title do |n|
  "Page Title #{n}"
end

Factory.define :page do |f|
  f.title { Factory.next(:page_title) }
  f.body "dummy body"
end

Factory.define :page_with_content, :parent => :page do |f|
  f.regions {|a| [a.association(:region_with_nodes), a.association(:region)] }
end
