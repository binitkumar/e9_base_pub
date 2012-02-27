module E9::Social::Clients
  module Twitter
    extend ActiveSupport::Concern

    included do
      validates :twitter_comment, :length => { :maximum => ::SocialFeeds::TWITTER_COMMENT_MAX_LENGTH }
      before_save :twitter_before_save

      self._social_update_methods << :twitter_update!
    end

    def twitter_comment(*args)
      opts = args.extract_options!
      opts.merge!(:bitly => true) if opts[:append_link]
      _process_liquid_comment args.shift || _twitter_comment || _twitter_template, opts.merge(:length => ::SocialFeeds::TWITTER_COMMENT_MAX_LENGTH)
    end

    def generate_twitter_argument_hash(options = {})
      Hash[:text => twitter_comment(options[:text], :render => true, :length => true, :append_link => true)]
    end

    def twitter_update!(hash = nil)
      if _post_to_twitter?
        begin 
          hash ||= generate_twitter_argument_hash
          raise "Twitter hash missing and failed to generate" if hash.blank?
          ::TwitterStatus.create(hash)
        rescue => e
          Rails.logger.error("Error sending twitter message for #{self.class.name}[#{id}]: #{e.message}")
        end
      end
    end

    def _twitter_comment;    end
    def _twitter_template;   end
    def _post_to_twitter?;   end
    def twitter_before_save; end

    protected :_twitter_comment, :_twitter_template, :twitter_before_save, :_post_to_twitter?
  end
end
