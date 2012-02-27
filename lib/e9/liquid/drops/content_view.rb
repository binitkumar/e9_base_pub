module E9::Liquid::Drops
  class ContentView < E9::Liquid::Drops::Linkable
    source_methods :id, :title, :description, :meta_description, :meta_keywords

    #
    # NOTE The more correct thing here would probably be to return a DateTime drop
    #      which translates to default on to_s but can be passed to a localize filter
    #      by name
    
    def created_at
      ::I18n.l(@object.created_at) if @object.created_at
    end

    def published_at
      ::I18n.l(@object.published_at) if @object.published_at
    end

    def created_date
      ::I18n.l(@object.created_at.to_date) if @object.created_at
    end

    def published_date
      ::I18n.l(@object.published_at.to_date) if @object.published_at
    end

    def author 
      ::E9::Liquid::Drops::User.new(@object.try(:author))
    end

    def thumb_url
      @object.try(:thumb_url)
    end

    def wide_thumb_url
      @object.respond_to?(:wide_thumb) ? @object.wide_thumb_url : thumb_url
    end

    def embeddable_url
      @object.respond_to?(:embeddable) ? @object.embeddable_url : thumb_url
    end

    # NOTE All content_views respond_to #image (it's a db column). They also
    # all respond_to :image_url (because of Image resource routes and ContentView 
    # including URLHelpers through Linkable).  Slide overrides this method with
    # its mount, but ContentView.new.image_url is a method and will throw an
    # exception, so take care.
    #
    def image_url
      @object.image && @object.image.respond_to?(:url) ? @object.image.url : thumb_url
    end

    def summary
      @object.try(:description)
    end

    def parent
      @object.parent.to_liquid if @object.parent.present?
    end
  end
end
