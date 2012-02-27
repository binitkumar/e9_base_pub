module E9::ActiveRecord
  module Anchorable
    def to_anchor
      if new_record?
        ''
      else
        @_anchor_name ||= "#{self.class.model_name.element}_#{id}".freeze
      end
    end
  end
end
