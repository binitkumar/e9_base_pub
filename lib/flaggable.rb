module Flaggable
  module InstanceMethods
    def flagged?
      !!flag && !flag.destroyed?
    end
  end

  def self.included(base)
    base.send :has_one, :flag, :as => :flaggable, :dependent => :destroy
    base.send :include, InstanceMethods
  end
end
