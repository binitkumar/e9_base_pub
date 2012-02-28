wysiwyg = Page.find_by_title "WYSIWYG Style Test With A Very Very Very Very Very Very Very Very Very Very Long Title"

wysiwyg.reset_layout!

wysiwyg.region('right').renderables = [
  FeedWidget.find_by_name("Page & Blog Feed With All Data"),
  FeedWidget.find_by_name("Slides - Images Only Feed"),
  FeedWidget.find_by_name("FAQ Feed With Image & Title"),
  FeedWidget.find_by_name("Forum Feed - Image, Title & Summary"),
  FeedWidget.find_by_name("Event Feed"),
  Poll.first,
  Snippet.find_by_name("Large Text Sidebar Snippet"),
  FeedWidget.find_by_identifier("top_feed_one"),
  FeedWidget.find_by_identifier("top_feed_two"),
  Offer.first
]
