require 'draper'

module Draper
  class DecoratedEnumerableProxy

    # ripped from activerecord relation
    def as_json(options={}) #:nodoc:
      to_a.as_json(options)
    end
  end

  module ModelSupport::ClassMethods
    # NOTE I don't see why we need do constantize here.  Why not just
    # inform the class about the decorator instead of hoping the class infers it?
    def decorate(context = {})
      @decorator_class ||= "#{model_name}Decorator".constantize

      block_given? ? 
        yield(@decorator_class.decorate(self.scoped)) :
        @decorator_class.decorate(self.scoped)
    end
  end
end
