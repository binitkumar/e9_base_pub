require 'active_support/string_inquirer'

module E9
  module Roles
    class Role < ActiveSupport::StringInquirer
      include Comparable

      def role; self end

      # NOTE Take care to call #role on strings when doing role <=> string comparisons to avoid potentially confusing results
      def <=>(other)
        if is?(other)
          0
        else
          includes?(other) ? 1 : -1
        end
      end

      def title
        E9::Roles.title_for(self)
      end

      def description
        E9::Roles.description_for(self)
      end

      def included
        E9::Roles.roles_for(self)
      end
      alias :roles :included

      # TODO lesser is a misnomer, included_minus_self?
      def lesser
        included - [self]
      end
      alias :included_minus_self :lesser

      def included_by
        E9::Roles.list.select {|role| role.role > self }
      end

      def self_and_included_by
        included_by.unshift self
      end

      def includes?(other)
        included.member?(other.role)
      end

      def is?(other)
        self == other.role
      end

      def is_omnipotent?
        E9::Roles.omnipotent_role?(self)
      end
    end
  end
end
