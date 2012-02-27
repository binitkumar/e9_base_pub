require 'fb_graph'

class FacebookPost < FbGraph::Post
  PER_PAGE = 5

  extend  ActiveModel::Naming
  include ActiveModel::Conversion

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
  
  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    (attr || '').to_s.titleize
  end

  def valid?
    errors.clear

    if link.present? && link !~ /^(https?:\/\/|\/)/
      errors.add(:link, 'Link is not valid')
    end

    if message.empty?
      errors.add(:message, 'Message cannot be blank')
    elsif message.length > 400
      errors.add(:message, 'Facebook message is too long. 400 characters is the maximum.')
    end

    errors.empty?
  end

  def self.lookup_ancestors
    [self]
  end

  def self.i18n_scope
    :facebook_posts
  end

  class << self
    def access_token; E9::Config[:facebook_access_token] end
    def page_id;      E9::Config[:facebook_company_page_id] end

    def user(refresh = true)
      @_user = nil if refresh
      @_user ||= FbGraph::User.me(access_token)
    end

    def accounts(refresh = true)
      @_accounts = nil if refresh
      @_accounts ||= user(refresh).try(:accounts) || []
    end

    def page(refresh = true)
      @_page = nil if refresh
      @_page ||= accounts(refresh).detect {|a| a.identifier == page_id } || accounts.first
    end

    def link(refresh = true)
      @_link = nil if refresh
      @_link ||= page(refresh).link || page.fetch.link rescue ''
    end

    def find(identifier)
      fetch(identifier, :access_token => user.access_token)
    rescue FbGraph::Exception => e
      log_exception('find', e)
      nil
    end

    def create(params = {})
      record = new(params)

      if !record.valid?
        record
      else
        page.feed!(params.merge(:access_token => page.access_token))
      end

    rescue FbGraph::Exception => e
      log_exception('create', e)
      new(params).tap do |obj|
        obj.errors.add(:base, e.message)
      end
    end

    def asynchronous_create(*args)
      create(*args)
    end
    handle_asynchronously :asynchronous_create

    def all(options = {})
      options[:limit] ||= PER_PAGE

      page.feed(options.merge(:access_token => user.access_token))
    rescue FbGraph::Exception => e
      log_exception('all', e)
      FbGraph::Connection.new(nil, nil)
    end

    def log_exception(method, e)
      Rails.logger.error("Exception in FacebookPost##{method}: #{e.message}")
    end

    def attributize(parent)
      attributes = {}
      attributes[:identifier]     = parent.identifier
      attributes[:endpoint]       = parent.endpoint
      attributes[:from]           = parent.from
      attributes[:to]             = parent.to
      attributes[:message]        = parent.message
      attributes[:picture]        = parent.picture
      attributes[:link]           = parent.link
      attributes[:name]           = parent.name
      attributes[:caption]        = parent.caption
      attributes[:description]    = parent.description
      attributes[:source]         = parent.source
      attributes[:icon]           = parent.icon
      attributes[:attribution]    = parent.attribution
      attributes[:actions]        = parent.actions
      attributes[:likes]          = parent.likes
      attributes[:created_time]   = parent.created_time
      attributes[:updated_time]   = parent.updated_time
      attributes
    end
  end

  # FbGraph::Post's initalize requires an identifier
  def initialize(*args)
    attributes = args.extract_options!
    attributes[:identifier] ||= args.shift || attributes[:id]
    super(attributes[:identifier], attributes)
  end

  # this is unnecessary
  #def save
    #self.class.create(self.class.attributize(self))
  #end

  def destroy
    super
  rescue => e
    errors.add(:base, e.message)
    false
  end

  alias :id :identifier

  def to_param
    identifier.to_s if persisted?
  end

  def persisted?
    # NOTE FbGraph::Post's default identifier is an empty hash, hence blank?
    !identifier.blank?
  end
end
