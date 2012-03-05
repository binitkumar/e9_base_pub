module E9::Rack
  #
  # Middleware to redirect www.* to .*
  #
  # If the `reverse` option is passed it will do the opposite, redirecting
  # .* to www.*
  #
  class WWWRedirect
    HasWWW = /^www\./i

    attr_reader :reverse

    def initialize(app, options={})
      @app     = app
      @reverse = if options[:reverse].nil? ? false : options[:reverse]
    end

    def call(env)
      if should_redirect?
        [301, redirect_headers(env), ["Moved Permanently\n"]]
      else
        @app.call(env)
      end
    end

    private

    def has_www?(env)
      !!HasWWW.match(env['HTTP_HOST'])
    end

    def should_redirect?(env)
      has_www? != reverse
    end

    def redirect_headers(env)
      location = Rack::Request.new(env).url.send(:sub, 
        *(reverse ? [/www\./, ''] : [/:\/\//, 'www'])
      )

      { 'Location' => location, 'Content-Type' => 'text/html' }
    end
  end
end
