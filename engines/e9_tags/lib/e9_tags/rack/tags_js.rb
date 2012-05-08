module E9Tags::Rack
  class TagsJs
    def self.call(env)
      if env["PATH_INFO"] =~ /^\/js\/tags/
        rel  = ::Tagging
                 .joins(:tag)
                 .order('tags.name')
                 .select('distinct taggings.context, tags.name')

        retv = ::Tagging.connection
                 .select_rows(rel.to_sql, 'Tags JS')
                 .inject({}) {|h, row| (h[row.first] ||= []) << row.last; h } 

        js   = ";window.e9=window.e9||{};window.e9.tags=#{retv.to_json};"

        ::E9::Rack::NoSession.set_header!(env)

        [200, {"Content-Type" => "text/javascript", "Cache-Control" => "private, max-age=3600"}, [js]]
      else
        [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
      end
    end
  end
end
