module E9::Helpers
  #
  # This module exists basically to solve the problem of slideshows
  # having multiple routes based on whether or not they're persisted.
  # (a new slideshow is actually a "custom" slideshow; a search on slides)
  #
  # It's inluded by application controller and Linkable
  #
  # NOTE this does not include Rails url_helpers, so if the mixee does not
  #      already include it, it must do so.
  #
  module Urls
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        send :helper_method, :slideshow_slide_url, :slideshow_slide_path
      end
    end

    def slideshow_slide_url(slideshow, slide, options = {})
      if slideshow.persisted?
        send :slideshow_url, slideshow, options.merge(:anchor => slide.to_param)
      else
        send :slides_url, options.merge(:anchor => slide.to_param)
      end
    end

    def slideshow_slide_path(slideshow, slide, options = {})
      slideshow_slide_url(slideshow, slide, options.merge(:only_path => true))
    end
  end
end
