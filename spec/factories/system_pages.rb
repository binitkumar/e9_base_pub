Factory.sequence :system_page_title do |n|
  "System Page Title #{n}"
end

Factory.sequence :system_page_identifier do |n|
  "system_page_identifier_#{n}"
end

Factory.define :system_page do |f|
  f.title { Factory.next(:system_page_title) }
  f.identifier { Factory.next(:system_page_identifier) }
end
