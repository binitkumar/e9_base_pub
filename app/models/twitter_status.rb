require 'twitter_oauth'

class TwitterStatus
  PER_PAGE = 5

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include E9::SimpleAttributeMethods

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
  
  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  def self.i18n_scope
    :twitter_statuses
  end

  # limit the attributes?
  define_attribute_methods [:text, :id, :created_at, :user, :error]

  class << self
    def client
      @_client = TwitterOAuth::Client.new(
        :consumer_key    => E9::Config[:twitter_app_id],
        :consumer_secret => E9::Config[:twitter_app_secret],
        :token           => E9::Config[:twitter_access_token],
        :secret          => E9::Config[:twitter_secret_token]
      )
    end

    def find(id)
      result = client.status(id)
      new(result) unless result['error']
    end

    def create(params = {})
      record = new(params)

      return record unless record.valid?

      new(client.update(record.text)).tap do |obj|
        obj.errors.add(:base, obj.error) if obj.error
      end
    end

    def asynchronous_create(*args)
      create(*args)
    end
    handle_asynchronously :asynchronous_create

    def destroy(id)
      id = id.id if id.is_a?(self)
      result = client.status_destroy(id)

      new(result).tap do |obj|
        obj.errors.add(:base, result['error']) if result['error']
      end
    end

    def all(options = {})
      options.symbolize_keys! if options.respond_to?(:symbolize_keys!)

      page     = options[:page]     || 1
      per_page = options[:per_page] || PER_PAGE

      timeline = client.user_timeline(:page => page, :count => per_page)

      # NOTE this was returning a hash but only if there was an error?
      if timeline.is_a?(Hash) && timeline['error']
        raise timeline['error']
      end

      count = timeline.first['user']['statuses_count'] rescue 0

      WillPaginate::Collection.create(page, per_page, count) do |pager|
        pager.replace(timeline.map {|result| new(result) })
      end
    rescue => e
      Rails.logger.error("Twitter Error in #all: #{e}")
      WillPaginate::Collection.new(1, 1, 0)
    end
  end

  def initialize(attrs = {})
    raise ArgumentError, "initialize takes a hash of attributes" unless attrs.kind_of?(Hash)
    self.attributes = attrs.stringify_keys
  end

  def created_at
    if ca = attribute("created_at")
      DateTime.parse(ca)
    end
  end

  def persisted?
    !id.nil?
  end

  def update(attrs = {})
    self.attributes.merge!(attrs.stringify_keys)
  end

  def valid?
    errors.clear
    errors.add(:base, 'Message has already been posted') if persisted?

    if text.blank?
      errors.add(:text, 'Message cannot be empty')         
    elsif text.length > 140
      errors.add(:text, 'Message is limited to 140 characters')
    end

    errors.empty?
  end

  def destroy
    self.class.destroy(self)
  end
end
