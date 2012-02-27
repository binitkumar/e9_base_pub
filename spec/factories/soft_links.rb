# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :soft_link do |f|
  f.association :link
end

Factory.define :soft_link_with_name do |f|
  f.name "Some Soft Link"
  f.delegate_title_to_link true
end

Factory.define :soft_link_for_user_page, :parent => :soft_link do |f|
end
