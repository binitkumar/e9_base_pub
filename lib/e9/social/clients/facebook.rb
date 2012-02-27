module E9::Social::Clients
  module Facebook
    extend ActiveSupport::Concern

    included do
      validates :facebook_comment, :length => { :maximum => ::SocialFeeds::FACEBOOK_COMMENT_MAX_LENGTH }
      before_save :facebook_before_save

      self._social_update_methods << :facebook_update!
    end

    def facebook_comment(*args)
      opts = args.extract_options!
      _process_liquid_comment args.shift || _facebook_comment || _facebook_template, opts.merge(:length => ::SocialFeeds::FACEBOOK_COMMENT_MAX_LENGTH)
    end

    def generate_facebook_argument_hash(opts = {})
      Hash[:message => facebook_comment(opts[:message], :render => true, :length => true, :append_link => false)]
    end

    def facebook_update!(hash = nil)
      if _post_to_facebook?
        begin 
          hash ||= generate_facebook_argument_hash
          raise "Facebook hash missing and failed to generate" if hash.blank?
          ::FacebookPost.create(hash)
        rescue => e
          Rails.logger.error("Error sending facebook message for #{self.class.name}[#{id}]: #{e.message}")
        end
      end
    end

    def facebook_before_save; end
    def _facebook_template;   end
    def _post_to_facebook?;   end
    def _facebook_comment;    end

    protected :_facebook_comment, :_facebook_template, :facebook_before_save, :_post_to_facebook?
  end
end
