class Liquifier

  def self.call(env)
    if env["PATH_INFO"] =~ /^\/liquifier/
      @env  = Rack::Request.new(env)

      response = ''

      if (page_params = @env.params['page']) && (template = @env.params['template'])
        page     = Page.new(page_params)
        response = Liquid::Template.parse(template).render(E9::Liquid::Env.new.merge('page' => page)) rescue ''
      end

      [200, {"Content-Type" => "application/json", "Cache-Control" => "max-age=3600, must-revalidate"}, [response.to_json]]
    else
      [404, {"Content-Type" => "text/html", "X-Cascade" => "pass"}, ["Not Found"]]
    end
  end
end
