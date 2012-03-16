Layout.all.each {|layout| layout.init! }

forum_layout = Layout.for(Forum)
blog_layout  = Layout.for(Blog)
admin_layout = Layout.find_by_identifier('user_page_admin')
home_layout  = Layout.find_by_identifier('user_page_home')
layouts      = Layout.all

s = Snippet.find_by_name("Main Menu")
(layouts - [admin_layout]).each do |layout| 
  layout.region('main-nav').add_renderable!(s) 
end

s = Snippet.find_by_name("Admin Menu")
admin_layout.region("main-nav").add_renderable!(s)

s = Snippet.find_by_name("Top Nav Content")
layouts.each do |layout| 
  layout.region('top-nav').add_renderable!(s)
end

s = Snippet.find_by_name("Footer Menu")
layouts.map {|layout| layout.region('footer') }.compact.each do |region| 
  region.add_renderable!(s)
end

s = FeedWidget.find_by_identifier("footer_feed_1")
layouts.map {|layout| layout.region('footer') }.compact.each do |region| 
  region.add_renderable!(s)
end

s = Snippet.find_by_name("Social Module")
layouts.each do |layout| 
  layout.region('footer').add_renderable!(s)
end

s = FeedWidget.find_by_identifier("footer_feed_2")
layouts.map {|layout| layout.region('footer') }.compact.each do |region| 
  region.add_renderable!(s)
end

s = Snippet.find_by_name("Bottom Footer")
layouts.each do |layout| 
  layout.region('bottom-footer').add_renderable!(s)
end

s = Banner.find_by_name("Main Banner")
layouts.map {|layout| layout.region('main-banner') }.compact.each do |region| 
  region.add_renderable!(s)
end

s = Partial.find_by_name("Forum Menu")
forum_layout.region("right").add_renderable!(s)

s = Partial.find_by_name("Blog Menu")
blog_layout.region("right").add_renderable!(s)

s = Snippet.find_by_name("Previous/Next Links")
blog_layout.region("right").add_renderable!(s)

s = FeedWidget.find_by_identifier("blog_feed")
layouts.map {|layout| layout.region('right') }.compact.each do |region| 
  region.add_renderable!(s)
end

snippets = E9::Seeds.fetch_fixtures("Snippet", %w(home_snippet_1 home_snippet_2 home_snippet_3))
home_layout.region('content-bottom').add_renderables!(snippets)
