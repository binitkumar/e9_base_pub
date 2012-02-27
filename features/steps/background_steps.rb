#Given /^the main menu is defined$/ do
  #mv = MenuView.create(:name => "Main Menu", :menu => Menu.create(:name => "Main Menu", :master => true)) 
  #HomePage.master.region("main-nav").add_renderable!(mv)
#end

#Given /^the header nav is defined$/ do
  #header_menu = Menu.find_or_create_by_name("Header Nav Menu")
  #Link.create(:parent => header_menu, :name => I18n.t(:admin_link, :scope => :e9), :href => admin_root_path, :role => Role::ADMINISTRATOR)
  #Link.create(:parent => header_menu, :name => I18n.t(:employees_link, :scope => :e9), :href => employee_blog_posts_path, :role => Role::EMPLOYEE)
  #Link.create(:parent => header_menu, :name => I18n.t(:profile_title, :scope => :e9), :href => profile_path, :role => Role::USER)
  #Link.create(:parent => header_menu, :name => I18n.t(:edit_profile_title, :scope => :e9), :href => edit_profile_path, :role => Role::USER)
  #Link.create(:parent => header_menu, :name => I18n.t(:sign_out, :scope => :e9), :href => destroy_user_session_path, :role => Role::USER)
  #Link.create(:parent => header_menu, :name => I18n.t(:sign_in, :scope => :e9), :href => new_user_session_path, :role => Role::GUEST)
  #Link.create(:parent => header_menu, :name => I18n.t(:sign_up, :scope => :e9), :href => new_user_session_path, :role => Role::GUEST)
  #HomePage.master.region("top-nav").add_renderable!(MenuView.create(:name => "Header Nav Menu", :menu => header_menu))
#end

#Given /^a blog menu is defined$/ do
  #Then %{the main menu is defined}
  #main_menu = Menu.find_by_name("Main Menu")
  #blog = DummyLinkable.create(:config_key => 'blog_name', :href => "/blog", :link_type => 'blog')
  #Link.create(:parent => main_menu, :name => "{{ blog_name }}", :linkable => blog)
#end

#Given /^the blog subnav is defined$/ do
  #blog_menu = Partial.create(:name => "Blog Menu", :file => "partials/blog_menu")
  #BlogPage.master.region('left-col').add_renderable!(blog_menu)
#end

#Given %r/^there are (\d+) published blog posts$/ do |n|
  #n.to_i.times { Factory.create(:published_blog_post) }
#end

#Given %r/^there are (\d+) published blog posts from "([^"]*)"$/ do |n, date|
  #n.to_i.times { Factory.create(:published_blog_post, :published_at => DateTime.parse(date)) }
#end

#Given /^a forum menu is defined$/ do
  #Then %{the main menu is defined}
  #main_menu = Menu.find_by_name("Main Menu")
  #forum = DummyLinkable.create(:config_key => 'forum_name', :href => "/forums", :link_type => 'forum')
  #Link.create(:parent => main_menu, :name => "{{ forum_name }}", :linkable => forum)
#end

#Given /^there are (\d+) forum categories$/ do |n|
  #n.to_i.times { Factory.create(:forum) }
#end

#Given /^a blog is defined$/ do |n|
  #Factory.create(:blog_post)
#end

#Given /^a blog is defined$/ do |n|
  #Factory.create(:forum)
#end

#Given /^the admin menu is defined$/ do
  #Then %{the header nav is defined}
  #admin_menu = Menu.create(:name => "Admin Menu")
  #Layout.find_by_name("Administrator").region("sub-nav").add_renderable!(MenuView.create(:name => "Admin Menu", :menu => admin_menu))

  #admin_home  = Link.create(:parent => admin_menu, :name => "Admin Home", :href => "/admin")
  #users_nav   = Link.create(:parent => admin_menu, :name => "Users", :href => "/admin/users")
  #content_nav = Link.create(:parent => admin_menu, :name => "Content", :href => "/admin/content")
  #email_nav   = Link.create(:parent => admin_menu, :name => "Email", :href => "/admin/email")
  #site_nav    = Link.create(:parent => admin_menu, :name => "Site", :href => "/admin/site")
  #help_nav    = Link.create(:parent => admin_menu, :name => "Help", :href => "/admin/help")

  #Link.create(:parent => users_nav,   :name => "Users", :href => "/admin/users")
  #Link.create(:parent => users_nav,   :name => 'View Flagged Posts ({{flagged_posts}})', :href => "/admin/users/flagged_posts").save(:validate => false)

  #Link.create(:parent => content_nav, :name => "Pages", :href => "/admin/content/pages")
  #Link.create(:parent => content_nav, :name => "Menus", :href => "/admin/content/menus")
  #Link.create(:parent => content_nav, :name => "Snippets", :href => "/admin/content/snippets")
  #Link.create(:parent => content_nav, :name => "Categories", :href => "/admin/content/categories")
  #Link.create(:parent => content_nav, :name => "Share Sites", :href => "/admin/content/share_sites")
  #Link.create(:parent => content_nav, :name => "Layouts", :href => "/admin/content/layouts")
  #Link.create(:parent => content_nav, :name => "Admin Help", :href => "/admin/content/help", :role => Role::E9_USER)

  #Link.create(:parent => site_nav,  :name => "Site Settings", :href => "/admin/site/settings")
  #Link.create(:parent => site_nav,  :name => "Search Log", :href => "/admin/site/searches")
  #Link.create(:parent => site_nav,  :name => "Analytics", :href => "https://www.google.com/analytics/reporting/login", :new_window => true)

  #Link.create(:parent => email_nav, :name => "Pending Email", :href => "/admin/email/emails")
  #Link.create(:parent => email_nav, :name => "Sent Email Log", :href => "/admin/email/emails/sent")
  #Link.create(:parent => email_nav, :name => "System Email", :href => "/admin/email/system")
  #Link.create(:parent => email_nav, :name => "Mailing Lists", :href => "/admin/email/lists")

  #Link.create(:parent => help_nav, :name => "Help", :href => "/admin/help")
  #Link.create(:parent => help_nav, :name => "Custom Help", :href => "/admin/help/custom", :v_config => 'custom_help')
#end
