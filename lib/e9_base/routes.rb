if defined?(Rails::Application)
  class HtmlOnlyConstraint
    def matches?(request)
      request.path =~ /\/[^\.]*$/
    end
  end

  Rails.application.routes.draw do
    #get '/*unrecognized_route', :to => 'errors#routing', :constraints => HtmlOnlyConstraint.new
    get '/*unrecognized_route', :to => 'errors#routing'
  end
end
