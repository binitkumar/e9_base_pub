class PermalinkExistsConstraint
  #NotRoutingError       = /\/(?!routing_error)/
  HasNoExtension        = /\/[^\.]+$/
  LastSegmentPermalink  = /\/([^\/]+)$/
  Permalink             = /^\/(?:nl\/)?([^\.]+)$/

  def initialize(last_segment_only = false)
    @last_segment_only = last_segment_only
  end

  def matches?(request)
    # vidibus routing_error re-routes to "/routing_error" route internally, skip
    #request.path =~ NotRoutingError               &&

    # skip anything with an extension, as currently permalinks do not use extensions
    request.path =~ HasNoExtension                &&

    # matches permalink?
    (permalink = request.path[@last_segment_only ? LastSegmentPermalink : Permalink, 1]) &&

    # and finally, permalink exists?
    ContentView.permalink_exists?(permalink)
  end
end
