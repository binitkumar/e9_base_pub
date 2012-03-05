module E9::Rack
  #
  # Middleware to redirect www.* to .*
  #
  # If the `reverse` option is passed it will do the opposite, redirecting
  # .* to www.*
  #
  class WWWRedirect
    HasWWW      = /^www\./i
    ArgsToWWW   = [/:\/\//,      '://www.'].freeze
    ArgsFromWWW = [/:\/\/www\./, '://'    ].freeze

    attr_reader :reverse, :sub_args

    def initialize(app, options={})
      @app      = app
      @reverse  = options[:reverse].nil? ? false : options[:reverse]
      @sub_args = reverse ? ArgsToWWW : ArgsFromWWW
    end

    def call(env)
      if should_redirect?(env)
        [301, redirect_headers(env), ["Moved Permanently\n"]]
      else
        @app.call(env)
      end
    end

    private

    def should_redirect?(env)
      !!HasWWW.match(env['HTTP_HOST']) != reverse
    end

    def redirect_location(env)
      Rack::Request.new(env).url.sub *sub_args
    end

    def redirect_headers(env)
      { 
        'Location'     => redirect_location(env),
        'Content-Type' => 'text/html'
      }
    end
  end
end
