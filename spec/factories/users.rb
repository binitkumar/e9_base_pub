Factory.sequence :newsletter do |n|
  "somename_#{n}@example.com"
end

Factory.define :user do |f|
  f.first_name "Joe"
  f.email { Factory.next(:newsletter) }
  f.username {|a| a.email }
  f.password "somepassword"
  f.password_confirmation "somepassword"
end

Factory.define :user_employee, :parent => :user do |f|
  f.role 'employee'
end

Factory.define :user_administrator, :parent => :user do |f|
  f.role 'administrator'
end

Factory.define :user_superuser, :parent => :user do |f|
  f.role 'superuser'
end

Factory.define :user_e9, :parent => :user do |f|
  f.role 'e9_user'
end
