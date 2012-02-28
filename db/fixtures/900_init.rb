[ContentView, Forum, Blog].each do |klass|
  klass.all.each &:reset_layout!
end

pages = E9Seeds.fetch_fixtures('SystemPage', %w(
  sign_in
  sign_up
  manage_account 
  email_preferences
  passwords
  profile
  edit_profile
  profiles
  slideshows
  faqs
))

feed_widget = E9Seeds.fetch_fixture('FeedWidget', 'all_data')

pages.map {|page| page.region('right') }.compact.each do |region|
  region.add_renderable!(feed_widget)
end
