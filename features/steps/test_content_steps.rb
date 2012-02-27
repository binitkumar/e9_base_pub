Given /^the test web skeleton$/ do
  # TODO need to figure out cleaner way to start cucumber than db/seeding
  Page.destroy_all
  Layout.destroy_all
  Menu.destroy_all

  main_nav = Menu.create(:name => "Home", :system => true)

  layout = Layout.create(
    :name => "Default",
    :template => "application",
    :regions => [Region.create(:name => "main_nav", :renderable => main_nav)]
  )

  home   = layout.prototype!(SystemPage, :title => "Home Page", :permalink => "/", :body => "Home Page Body")
  page_1 = layout.prototype!(UserPage, :title => "Page 1", :body => "Page 1 Body")
  page_2 = layout.prototype!(UserPage, :title => "Page 2", :body => "Page 2 Body")

  main_nav.update_attribute(:page, home)
  main_nav.children.create(:name => "Home Link", :page => home)
  main_nav.children.create(:name => "Page 1 Link", :page => page_1)
  main_nav.children.create(:name => "Page 2 Link", :page => page_2)

  Page.count.should == 3
  Menu.count.should == 4
end
