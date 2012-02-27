module SslRequirement
  def self.included(controller)
    controller.extend(ClassMethods)
    controller.before_filter(:ensure_proper_protocol)
  end

  module ClassMethods
    def ssl_required(*actions)
      write_inheritable_array(:ssl_required_actions, actions.empty? ? :all : actions)
    end

    def ssl_allowed(*actions)
      write_inheritable_array(:ssl_allowed_actions, actions.empty? ? :all : actions)
    end
  end
  
  protected
    def ssl_required?
      return false if Rails.env.development?
      actions = self.class.read_inheritable_attribute(:ssl_required_actions)
      actions ? actions == :all || actions.include?(action_name.to_sym) : false
    end
    
    def ssl_allowed?
      return true if Rails.env.development?
      actions = self.class.read_inheritable_attribute(:ssl_allowed_actions)
      actions ? actions == :all || actions.include?(action_name.to_sym) : false
    end

  private
    def ensure_proper_protocol
      return true if ssl_allowed?

      if ssl_required? && !request.ssl?
        redirect_to url_for(params.merge(:protocol => "https://"))
        flash.keep
        return false
      elsif request.ssl? && !ssl_required?
        redirect_to url_for(params.merge(:protocol => "http://"))
        flash.keep
        return false
      end
    end
end
