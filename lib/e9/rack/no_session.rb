module E9::Rack
  class NoSession
    ENV_KEY = 'e9.rack.no_session'

    def self.set_header!(env)
      env[ENV_KEY] = 1
    end

    def initialize(app, options={})
      @app = app
      @key = options[:key]
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      status, headers, body = @app.call(env)

      # NOTE delete_cookie_header! actually deletes the cookie on disk
      # by setting it to blank and expiring it
      if env[ENV_KEY]
        if @key
          Rack::Utils.delete_cookie_header! headers, @key
        else
          headers.delete 'Set-Cookie'
        end
      end

      [status, headers, body]
    end
  end
end
