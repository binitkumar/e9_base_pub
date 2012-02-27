Factory.sequence :layout_name do |n|
  "Layout #{n}"
end

Factory.sequence :layout_identifier do |n|
  "layout_id_#{n}"
end

Factory.define :layout do |f|
  f.name { Factory.next(:layout_name) }
  f.template "application"
  f.identifier { Factory.next(:layout_identifier) }
end

# TODO fgure out after filter to add content nodes
#Factory.define :layout_with_content, :parent => :layout do |f|
  #f.regions {|a| [a.association(:region_with_nodes), a.association(:region)] }
#end
