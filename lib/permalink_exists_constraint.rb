class PermalinkExistsConstraint
  def initialize(last_segment_only = false)
    @last_segment_only = last_segment_only
  end

  def matches?(request)
    permalink = request.path.dup

    permalink.sub!(/\..*$/, '')
    permalink.sub!(/.*\//, '') if @last_segment_only

    !permalink.blank? && ContentView.permalink_exists?(permalink)
  end
end
