Factory.sequence :region_name do |n|
  "some region name #{n}"
end

Factory.define :region do |f|
  f.name { Factory.next(:region_name) }
end

Factory.define :region_in_layout, :parent => :region do |f|
  f.association :view, :factory => :layout
end

Factory.define :region_in_page, :parent => :region do |f|
  f.association :view, :factory => :page
end

Factory.define :region_as_a_child, :parent => :region do |f|
  f.association :parent, :factory => :region
end

Factory.define :region_with_nodes, :parent => :region do |f|
  f.nodes {|a| [a.association(:node_with_snippet), a.association(:node_with_partial)] }
end
