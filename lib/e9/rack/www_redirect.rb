module E9::Rack
  class WWWRedirect
    REGEXP = /^www\./i

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['HTTP_HOST'] =~ REGEXP
        [301, redirection(env), ["Moved Permanently\n"]]
      else
        @app.call(env)
      end
    end

    private

    def redirection(env)
      { 
        'Location'     => Rack::Request.new(env).url.sub(/www\./i, ''),
        'Content-Type' => 'text/html' 
      }
    end
  end
end
