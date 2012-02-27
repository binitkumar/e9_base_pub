# Allow the metal piece to run in isolation
require File.expand_path('../../../config/environment',  __FILE__) unless defined?(Rails)

class SearchAutoCompleter
  DEFAULT_LIMIT = 10

  def self.call(env)
    if env["PATH_INFO"] =~ /^\/autocomplete\/search/
      terms = []

      if @term = Rack::Request.new(env).params['term']
        tags, taggings = ::Tag.arel_table, ::Tagging.arel_table

        relation = tags.join(taggings).on(tags[:id].eq(taggings[:tag_id])).
                      where(tags[:name].matches("#{@term}%")).
                      where(taggings[:context].matches('%__H__').not).
                      take(DEFAULT_LIMIT).
                      group(tags[:id]).
                      project(tags[:name], tags[:name].count.as('count')).
                      order('count DESC')

        terms = ::ActiveRecord::Base.connection.send(:select, relation.to_sql, 'Tag Autocomplete').map do |row| 
          { :label => "#{row['name']} - #{row['count']}", :value => row['name'], :count => row['count'] }
        end
      end

      [200, {"Content-Type" => "application/json", "Cache-Control" => "max-age=3600, must-revalidate"}, [terms.to_json]]
    else
      [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
    end
  end
end
