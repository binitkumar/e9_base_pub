module E9Crm::Rack
  class DealAutoCompleter
    DEFAULT_LIMIT = 10

    def self.call(env)
      params = Rack::Request.new(env).params
      
      if query = params['query'] || params['term']
        relation = 
          Deal.any_attrs_like('name', query, :matcher => '%s%%').
            limit(params['limit'] || DEFAULT_LIMIT).
            order('deals.name ASC')

        if params['except'] && (except = params['except'].scan(/(\d+),?/)) && !except.empty?
          relation = relation.where( Deal.arel_table[:id].not_in(except.flatten) )
        end

        deals = ::ActiveRecord::Base.connection.send(:select, relation.to_sql, 'Deal Autocomplete').map do |row|
          name = row['name']
          { :label => name, :value => name, :id => row['id'] }
        end
      else
        deals = []
      end

      [200, {"Content-Type" => "application/json", "Cache-Control" => "no-cache"}, [deals.to_json]]
    end
  end
end
