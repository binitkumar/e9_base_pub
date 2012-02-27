# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :partial do |f|
  f.name "blank partial"
end


Factory.define :partial_with_search_form, :parent => :partial do |f|
  f.name 'partial with search form'
  f.file 'search_form'
end

