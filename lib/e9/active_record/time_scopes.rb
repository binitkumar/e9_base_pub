module E9::ActiveRecord
  module TimeScopes
    extend ActiveSupport::Concern

    module ClassMethods

      def from_time *args
        scoped.where from_time_conditions(*args) 
      end

      def until_time *args
        scoped.where until_time_conditions(*args) 
      end

      def for_time_range *args
        scoped.where for_time_range_conditions(*args) 
      end

      def from_time_conditions(*args)
        args.flatten!
        for_time_range_conditions(args.shift, nil, args.extract_options!)
      end
      
      def until_time_conditions(*args)
        args.flatten!
        for_time_range_conditions(nil, args.shift, args.extract_options!)
      end

      def for_time_range_conditions(*args)
        opts = args.extract_options!
        args.flatten!

        time_column    = opts[:column] || :created_at
        column_is_date = columns_hash[time_column.to_s].type == :date

        # try to determine a datetime from each arg, skipping #to_time on passed strings because
        # it doesn't handle everything DateTime.parse can, e.g. 'yyyy/mm'
        args.map! do |t| 
          t.presence and 

            # handle string years 2010, etc.
            t.is_a?(String) && /^\d{4}$/.match(t) && Date.civil(t.to_i) ||

            # handle Time etc. (String#to_time doesn't handle yyyy/mm properly)
            !t.is_a?(String) && t.respond_to?(:to_time) && t.to_time || 

            # try to parse it
            DateTime.parse(t) rescue nil
        end

        # scan through again and transform all times to this zone
        unless column_is_date
          args.map! do |t|
            t.respond_to?(:to_time_in_current_zone) && 
              t.to_time_in_current_zone || t
          end
        end

        if !args.any?
          '1=0'.tap {|v| def v.to_sql; self end }
        else 
          table       = arel_table

          if opts[:alias]
            table = arel_table.alias(opts[:alias])
          end

          condition = if args.length == 1
            opts[:in] ||= 'month'
            d = args.compact.first
            range = case opts[:in].downcase.to_s
            when 'day'
              d = Date.new(d.year, d.month, d.day)
              d = d.to_time_in_current_zone unless column_is_date
              d...(d + 1.day)
            when 'month'
              d = Date.new(d.year, d.month)
              d = d.to_time_in_current_zone unless column_is_date
              d...(d + 1.month)
            when 'year'
              d = Date.new(d.year)
              d = d.to_time_in_current_zone unless column_is_date
              d...(d + 1.year)
            end
            table[time_column].in(range)
          elsif args.all?
            table[time_column].in(args[0]...args[1])
          elsif args[0]
            table[time_column].gteq(args[0])
          else
            table[time_column].lteq(args[1])
          end

          if opts[:allow_nil]
            condition = condition.or(table[:id].eq(nil))
          end

          if opts[:or]
            condition = condition.or(opts[:or])
          end

          condition
        end
      end
    end
  end
end
