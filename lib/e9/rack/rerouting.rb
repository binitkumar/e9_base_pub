module E9::Rack
  class Rerouting
    def initialize(app, options={})
      @app            = app
      @threes         = options[:threes] || {}
      @fours          = options[:fours] || []
      @ignore_formats = (options[:ignore_formats] || []).map(&:to_sym)
    end

    def call(env)
      dup.call!(env)
    end

    def call!(env)
      @env = env
      @request = Rack::Request.new(env)

      unless ignored_format?
        if location = find_redirect
          return redirect_to(location)
        else
          find_not_found
        end
      end

      @app.call(env)
    end

    private

      def ignored_format?
        ext = find_extension
        ext && @ignore_formats.member?(ext)
      end

      def find_extension
        ext = ::File.extname(@request.path_info)[1..-1]

        ext ||= begin
          accept = @env['HTTP_ACCEPT'].to_s.scan(/[^;,\s]*\/[^;,\s]*/)[0].to_s
          Rack::Mime::MIME_TYPES.invert[accept]
        end

        ext && ext.delete('.').to_sym
      rescue
        nil
      end

      def find_redirect
        @threes.each do |pattern, target|
          if match = pattern.match(@request.path)
            return target % match.captures
          end
        end

        nil
      end

      def find_not_found
        if @fours.any? {|pattern| pattern =~ @request.path }
          @env[::BaseController::FORCED_NOT_FOUND_HEADER] = 1
        end
      end

      def redirect_to(location)
        [301, redirect_headers(location), ["Moved Permanently\n"]]
      end

      def redirect_headers(location)
        {'Location' => location, 'Content-Type' => 'text/html'}
      end

  end
end
