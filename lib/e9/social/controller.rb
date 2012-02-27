module E9::Social
  module Controller
    extend ActiveSupport::Concern

    included do
      filter_access_to :social_form, :social_update, :context => :admin, :require => :update
      before_filter :set_social_resource, :only => [:social_form, :social_update]
    end

    def social_form
      respond_to do |format|
        format.html do
          if resource.role > 'user'.role
            head 403
          else
            render 'shared/social/form', :layout => !request.xhr?
          end
        end
      end
    end

    def social_update
      object = resource

      if opts = params[:facebook_post]
        if E9.true_value? opts.delete(:post)
          FacebookPost.asynchronous_create object.generate_facebook_argument_hash(opts)
        end
      end

      if opts = params[:twitter_status]
        if E9.true_value? opts.delete(:post)
          TwitterStatus.asynchronous_create object.generate_twitter_argument_hash(opts)
        end
      end

      social_update_render(object)
    end

    protected 

    def social_update_render(object)
      respond_with(object) do |format|
        format.js { head 200 }
      end
    end

    def set_social_resource
      resource
    end
  end
end
