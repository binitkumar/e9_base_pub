module E9::Liquid::Drops
  class Event < E9::Liquid::Drops::Page
    def time
      ::I18n.l(@object.event_time, :format => :event) if @object.event_time
    end

    def last_register_date
      ::I18n.l(@object.last_register_date.to_date) if @object.last_register_date
    end

    def capacity
      @object.try :event_capacity
    end

    def max_guests
      @object.try :event_max_guests
    end
  end
end
