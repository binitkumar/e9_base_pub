# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :node do |f|
end

Factory.define :node_with_snippet, :parent => :node do |f|
  f.association :renderable, :factory => :snippet
end

Factory.define :node_with_partial, :parent => :node do |f|
  f.association :renderable, :factory => :partial
end
