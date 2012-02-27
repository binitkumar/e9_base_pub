Factory.sequence(:region_type_name) do |n|
  "region_type_#{n}"
end

Factory.define :region_type do |f|
  f.name Factory.next(:region_type_name)
end

Factory.define :main_nav_region_type, :parent => :region_type do |f|
  f.name 'main_nav'
end

Factory.define :sub_nav_region_type, :parent => :region_type do |f|
  f.name 'sub_nav'
end

Factory.define :sidebar_region_type, :parent => :region_type do |f|
  f.name 'sidebar'
end
