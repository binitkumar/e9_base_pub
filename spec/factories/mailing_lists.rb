# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :mailing_list do |f|
  f.name "Stuff I need to know"
  f.description {|f| f.name }
end

Factory.define :system_mailing_list, :parent => :mailing_list do |f|
  f.system true
end

Factory.define :newsletter_mailing_list, :parent => :mailing_list do |f|
  f.newsletter true
end
