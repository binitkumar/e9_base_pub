module E9::ActiveRecord
  #
  # Contains useful "scopes" for ActiveRecord classes.
  #
  # Although named Scopes, this module actually contains no true scopes, 
  # persay, but only scopelike class methods.  This is due to the implementation
  # of ActiveRecord::Base and scope.  
  #
  module Scopes
    extend ActiveSupport::Concern
    include TimeScopes

    module ClassMethods
      #
      # Excludes records from a scope.  
      #
      # @records_or_ids Either records to be excluded or their ids
      #
      def excluding(*records_or_ids)
        records_or_ids.flatten!
        records_or_ids.map! &:to_param

        if records_or_ids.empty?
          scoped
        else
          scoped.where(arel_table[:id].not_in(records_or_ids))
        end
      end

      def union_of(other_scope, options = {})
        ast1 = scoped.except(:order).ast
        ast2 = other_scope.except(:order).ast

        union = Arel::Nodes::Union.new(ast1, ast2)

        from("#{union.to_sql} as #{arel_table.name}")
      end
    end
  end
end
