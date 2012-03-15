module E9::Liquid
  class Env < HashWithIndifferentAccess
    def initialize
      self['config']       = Drops::Config.new
      self['content_feed'] = Drops::ContentFeed.new
    end
  end
end
