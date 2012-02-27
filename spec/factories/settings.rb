Settings

Factory.sequence :settings_name do |n|
  "Settings #{n}"
end

Factory.define :settings do |f|
  f.name { Factory.next(:settings_name) }
end
