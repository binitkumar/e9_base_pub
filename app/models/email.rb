require 'liquid'
require 'chronic'

class Email < ActiveRecord::Base
  TEMPLATED_FIELDS = %w(html_body text_body subject)
  CHUNK_SIZE = 500

  class_inheritable_accessor :sub_types
  self.sub_types = []

  class_inheritable_accessor :_formats
  self._formats = %w(html text)

  def self.formats
    StringArrayInquirer.new(_formats)
  end

  delegate :formats, :to => 'self.class'

  belongs_to :author, :class_name => 'User'
  belongs_to :mailing_list

  has_many :email_deliveries

  validates :name, :presence => true, :uniqueness => { :allow_blank => true }
  validates :from, :to, :reply_to, :email => { :allow_blank => true }

  validates :subject,   :liquid   => true
  validates :html_body, :liquid   => true
  validates :text_body, :liquid   => true

  scope :active,   lambda {|v=true| where(:active => v) }
  scope :inactive, lambda { active(false) }
  scope :sub_type, lambda {|t| where(:sub_type => t) }

  scope :of_sub_type, lambda {|*sub_types| 
    sub_types.flatten!
    sub_types = sub_types.pop if sub_types.length == 1
    where(:sub_type => sub_types)
  }

  scope :newsletter, lambda { of_sub_type('newsletter') }
  scope :crm_template, lambda { of_sub_type('crm_template') }
  scope :lead_nourishing, lambda { of_sub_type('lead_nourishing') }

  # {{ email.message }}, passable as option to send!
  attr_accessor :message

  class << self
    def send!(id, *args)
      # finds the email and calls send!, this does not circumvent queue by default
      find(id).send!(*args)
    end

    def send_with_queue!(id, *args)
      opts = args.extract_options!
      send! id, *(args << opts.merge(:skip_queue => true))
    end
  end

  def role
    'administrator'.role
  end

  attr_writer :send_grid

  def send_grid?
    @send_grid != false
  end

  def plain_text?
    false
  end
  
  # Send mail.
  #
  # Unless in development or :skip_queue => true is passed, this will create a delayed job
  # to send the mail.
  #
  def send!(*args)
    opts = args.extract_options!

    unless opts.delete(:skip_queue)
      self.class.send_with_queue!(id, *args, opts)
      false
    else
      self.message = opts.delete(:message)

      case target = args.shift
      when String
        send_to_email(target, opts)
      when User, Array, ActiveRecord::Relation
        send_to_users(target, opts)
      when MailingList, nil
        send_to_list(target, opts)
      else false
      end
    end
  end

  def copy_attributes(opts = {})
    {}.tap do |attrs|
      unless opts[:for_delivery]
        attrs[:name]     = I18n.t(:copy_of, :name => name)
        attrs[:sub_type] = sub_type
      end

      attrs[:to]        = to
      attrs[:from]      = from
      attrs[:reply_to]  = reply_to
      attrs[:subject]   = subject
      attrs[:html_body] = html_body
      attrs[:text_body] = text_body
    end
  end

  def sub_type
    ActiveSupport::StringInquirer.new(read_attribute(:sub_type) || self.class.sub_types.first || '') 
  end

  def options
    @_options ||= default_options
  end

  def merges
    @_merges ||= Hash.new {|h,k| h[k] = [] }
  end

  def merges=(v)
    return false unless v.is_a?(Hash)
    v.default_proc ||= proc {|h,k| h[k] = [] }
    @_merges = v
  end

  def sender=(v)
    options[:sender] = v.is_a?(String) && User.new(:email => v) || v
  end

  def sender
    options[:sender]
  end

  def subscriptions=(*subs)
    subs.flatten!

    self.recipients = subs.map(&:user)

    merges[:unsubscribe_url] = subs.map do |sub|
      [:subscription_url, sub]
    end
  end

  def recipients
    merges[:recipients]
  end

  def substitutions
    merges.except(:recipients)
  end

  def recipients=(*users)
    users.flatten!
    users.compact!

    unless users.all? {|u| u.is_a?(User) }
      users = User.find_all_by_id(users.map(&:to_param))
    end

    bounced, users = users.partition {|user| user.has_bounced? }

    bounced.map!(&:email)
    Rails.logger.debug "Email #{id} send dropped #{bounced.length} bounced emails: #{bounced.join(', ')}"

    merges[:recipients] = users
    merges[:email]      = users.map(&:email)
    merges[:first_name] = users.map do |user|
      user.contact.try(:first_name) || user.first_name
    end

    # NOTE Mapping the IDs as strings is critical, as it inserts spaces into the final
    # JSON representation of the array which the mail gem needs to do line folding
    # in accordance with RFC2821.
    merges[:user_id] = users.map(&:to_param)
  end
  alias :recipient= :recipients=

  def render(field)
    return '' unless TEMPLATED_FIELDS.member?(field.to_s)
    opts = {}
    opts[:strip_whitespace] = field.to_s == 'html_body'

    templates(field, opts).render(options).tap do |retv|
      # Clear assigns.  There might be a better
      # way to do this (or prevent them from persisting)
      templates(field).assigns.replace({})
    end
  end
  alias :r :render

  def list_managed?
    false
  end

  def to_liquid
    E9::Liquid::Drops::Email.new(self)
  end

  def html_body
    read_attribute(:html_body) || ''
  end

  def text_body
    read_attribute(:text_body) || ''
  end

  def as_json(opts={})
    {}.tap do |hash|
      hash[:to]        = to
      hash[:reply_to]  = reply_to
      hash[:from]      = from 
      hash[:subject]   = r(:subject)
      hash[:html_body] = r(:html_body)
      hash[:text_body] = r(:text_body)
    end
  end

  protected

    def send_to_email(email, opts = {})
      send_to_users User.new(:email => email), opts
    end

    def send_to_users(*users)
      opts = users.extract_options!

      if opts[:test] || !list_managed? 
        self.recipients = users.flatten
        _do_send(opts)
      else
        send_to_list(nil, opts.merge(:recipients => users.flatten))
      end
    end

    def send_to_list(list, opts = {})
      list ||= self.mailing_list || MailingList.default

      unless list
        Rails.logger.warn("send_to_list called for email with no mailing list, args: #{opts.inspect}")
        return false
      end

      subs = list.subscriptions.includes(:user)

      # if recipients is passed, limit select by user_id
      if recips = opts.delete(:recipients)
        # NOTE recipients can be users or just ids
        subs = subs.where(:user_id => recips.map(&:to_param))
      end

      if excluding = opts.delete(:excluding)
        subs = subs.excluding(excluding)
      end

      if opts[:page] && opts[:page].respond_to?(:role) && opts[:page].role != E9::Roles.bottom
        subs = subs.joins(:user) & User.exclude_roles(opts[:page].role.lesser)
      end

      self.subscriptions = subs
      _do_send(opts)
    end

    def default_options
      HashWithIndifferentAccess.new({
        :email     => self,
        :sender    => User.new(:email => from),
        :recipient => recipients.first
      })
    end

    def templates(field, opts = {})
      @_templates ||= {}
      @_templates[field] ||= begin
        template = read_attribute(field) || ''

        # Hack, but let's swap out some stuff if this is a one off.
        # This is for the mailto template generator, mainly.
        unless send_grid?
          template = template.gsub(
            /#(first_name|email|user_id)#/, '{{ recipient.\1 }}')
        end

        if opts[:strip_whitespace]
          template = template.gsub(/\r\n/, "\n").gsub(/\n/, ' ').gsub(/\s+/, ' ')
        end

        Liquid::Template.parse(template)
      end
    end

    def reset_templates
      @_templates = nil
    end

    def _do_send(opts = {})
      # It's possible that we've reached the point of sending with no real recipients
      # (An empty mailing list, recipients that are flagged as hard bounces, etc).
      if recipients.empty?
        Rails.logger.warn("Email #{id} sent but found no recipients: (options #{opts.inspect})")
        return []
      end

      # :sender in options takes precedence over the sender= accessor
      if sender = opts.delete(:sender)
        self.sender = sender
      end

      # Refresh the config in case it's been changed.  This is necessary because
      # the config is typically refreshed by the application controller on web,
      # requests, but the mailer is most likely running in a separate thread.
      Mailer.refresh_config!

      # SendGrid's web API can't handle giant headers, so it's necessary to slice
      # large sends up into more manageable chunks so the custom headers aren't 
      # blown up to giant sizes by the merge variables.
      #
      # This is done by duping the actual merges and making multiple sends by 
      # iterating over them.
      #
      all_merges = merges.dup

      # slice up the recipient indices, 0 to length...
      (0...(recipients.length)).each_slice(CHUNK_SIZE) do |range|
        # ...and make a range out of each which will be used to slice the
        # subarrays in the merges
        range = (range.first)..(range.last)

        # clear our merges and step over the original merges, pulling out
        # one slice at a time.
        self.merges = {}
        all_merges.each do |h, k|
          self.merges[h] = k[range]
        end

        # then send as usual, but with only a slice of the merge vars
        Mailer.rendered_mail(self, opts).deliver
      end

      # return the recipients (Users)
      recipients
    end

end
