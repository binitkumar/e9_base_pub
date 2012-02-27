# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :subscription do |f|
  f.mailing_list {|a| a.association(:mailing_list) }
  f.user {|a| a.association(:user) }
end
