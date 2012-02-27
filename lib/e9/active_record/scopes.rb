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

      # NOTE this strips order from the scopes and returns an Array, NOT a scope
      def find_union_of(other_scope, options = {})
        ast1 = scoped.except(:order).ast
        ast2 = other_scope.except(:order).ast

        union = Arel::Nodes::Union.new(ast1, ast2)

        # to_sql gives us wrapping parens, e.g. (stmnt1 UNION stmnt2),
        # which for whatever reason breaks find_by_sql
        sql   = union.to_sql[1..-2].strip

        find_by_sql(sql)
      end
    end
  end
end
