Factory.sequence :blog_title do |n|
  "Blog Title #{n}"
end

Factory.define :blog_post do |f|
  f.title { Factory.next(:blog_title) }
  f.body "A blog post's body"
  f.association :blog
  f.author_string "some author"
  f.published_at DateTime.now
end

Factory.define :published_blog_post, :parent => :blog_post do |f|
  f.published true
  f.previously_published true
end
