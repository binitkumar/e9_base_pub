require 'fb_graph'

# This is a hack because for some reason, sometimes the collection is
# ending up as an Array rather than an FbGraph::Collection, which causes
# problems.
#
# I do now know why this happens, but it only seems to occur when called
# in a controller action.
#
module FbGraph
  class Connection
    def initialize(owner, connection, options = {})
      @owner = owner
      @options = options
      @connection = connection

      @collection = if options[:collection].is_a?(FbGraph::Collection)
        options[:collection]
      elsif options[:collection].present?
        FbGraph::Collection.new(options[:collection])
      else
        FbGraph::Collection.new
      end

      replace collection
    end
  end
end

# override fbgraph feed to return our facebookpost
module FbGraph::Connections::Feed
  def feed(options = {})
    posts = self.connection(:feed, options)
    posts.map! do |post|
      ::FacebookPost.new(post.delete(:id), post.merge(
        :access_token => options[:access_token] || self.access_token
      ))
    end
  end

  def feed!(options = {})
    post = post(options.merge(:connection => 'feed'))
    FacebookPost.new(post.delete(:id), options.merge(post).merge(
      :access_token => options[:access_token] || self.access_token
    ))
  end
end
