module E9::Liquid::Drops
  class Config < E9::Liquid::Drops::Base
    source_methods *Settings.defaulting_attributes

    def initialize
      @object = ::E9::Config.instance
    end
  end
end
