#puts "Setting up region types"
#region_types = []
#region_types << r_top_nav     = RegionType.create(:name => 'Top Nav', :domid => "top-nav", :expand_menus => RegionType::ExpandMenus::NEVER)
#region_types << r_main_nav    = RegionType.create(:name => 'Main Nav', :domid => "main-nav")
#region_types << r_sub_nav     = RegionType.create(:name => 'Sub Nav', :domid => "sub-nav", :expand_menus => RegionType::ExpandMenus::ACTIVE)
#region_types << r_left_col    = RegionType.create(:name => 'Left Column', :domid => "left-col", :role => Role::ADMINISTRATOR, :expand_menus => RegionType::ExpandMenus::ALWAYS)
#region_types << r_footer      = RegionType.create(:name => 'Bottom', :domid => "bottom", :role => Role::ADMINSTRATOR)

#main_menu = MenuView.create(:name => "Main Menu", :menu => Menu.create(:name => "Home", :master => true))

#puts "Setting up layouts"
#l1 = Layout.create(:name => "Master", :template => "application", :region_types => region_types)
#l1.region("main-nav").add_renderable!(main_menu)
#l1.prototype!(HomePage, :title => "Home", :master => true, :body => "!home!")

#l2 = Layout.create(:name => "Blog", :template => "blog", :region_types => region_types)
#l2.region("main-nav").add_renderable!(main_menu)
#l2.prototype!(BlogPage, :title => "Blog", :master => true)

#l3 = Layout.create(:name => "Forum", :template => "forum", :region_types => region_types)
#l3.region("main-nav").add_renderable!(main_menu)
#l3.prototype!(ForumPage, :title => "Forum", :master => true)

#l4 = Layout.create(:name => "Administrator", :template => "administrator", :region_types => region_types - [r_left_col])
#l4.region("main-nav").add_renderable!(main_menu)
#l4.prototype!(SystemPage, :title => "System", :master => true)

#puts "Preparing config"
#E9::Config.instance.save

#at_exit do
  #puts "Cleaning DB"
  #DatabaseCleaner.clean
#end
