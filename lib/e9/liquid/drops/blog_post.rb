module E9::Liquid::Drops
  class BlogPost < E9::Liquid::Drops::ContentView
    def next_record
      self.class.new(@object.next_record) if @object.next_record
    end

    def previous_record
      self.class.new(@object.previous_record) if @object.previous_record
    end
  end
end
