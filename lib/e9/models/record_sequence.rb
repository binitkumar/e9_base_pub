module E9::Models
  #
  # Simple interface, a class should override these methods to provide the
  # "next" and "previous" records in sequence, e.g. a blog post
  #
  module RecordSequence
    def next_record(*args); end
    def previous_record(*args); end
  end
end
