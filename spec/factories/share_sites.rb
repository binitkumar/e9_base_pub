Factory.sequence(:share_site_name) do |n|
  "Some Site [#{n}]"
end

Factory.define :share_site do |f|
  f.name Factory.next(:share_site_name)
  f.url "http://bananas.com"
end
