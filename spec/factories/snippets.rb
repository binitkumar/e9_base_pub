# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.sequence :snippet_name do |n|
  "snippet #{n}"
end

Factory.define :snippet do |f|
  f.name { Factory.next(:snippet_name) }
  f.template "plaintext template"
end

Factory.define :snippet_with_html, :parent => :snippet do |f|
  f.template "an <h1>HTML</h1> template"
end

Factory.define :snippet_with_liquid, :parent => :snippet do |f|
  f.template "{% welcome_username %}"
end
