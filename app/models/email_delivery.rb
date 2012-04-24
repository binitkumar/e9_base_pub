class EmailDelivery < ActiveRecord::Base
  include E9::HTML # for converting CRM text emails to HTML

  HTML_VARIABLE_SUB_REGEX = /href[=\s]+["'][^'"?]+(?:\?([^'"]*))?/
  TEXT_VARIABLE_SUB_REGEX = /https?:\/\/[^\s?]+(?:\?([^\s]*))?/

  belongs_to :campaign
  belongs_to :email

  validates :contact_ids, :presence => true
  validates :user_ids,    :presence => { :unless => lambda {|r| r.contact_ids.blank? } }

  validate do
    if campaign && !campaign.valid?
      if campaign.errors[:code].any?
        # these code errors are our concern, anything else we'll just say invalid
        # NOTE this makes use of a rails extension that saves the i18n error type
        campaign.errors[:code].each do |e|
          errors.add(:campaign, :"code_#{e.label}", :default => e)
        end
      else
        errors.add :campaign, :invalid 
      end
    end
  end

  validates :subject, :html_body, :text_body, :liquid => true 
  validates :subject, :presence => true
  validates :from, :to, :reply_to, :email => { :allow_blank => true }

  before_create :prepare_bodies
  after_create :deliver!

  # NOTE this scope piggybacks on campaign's page_views, outer joining
  #      in the same way that Campaign.reports does
  #
  #      It would probably be faster to do a single, separate query for
  #      Campaign views then pull that data into the form, but then we'd
  #      need to figure out another way to sort the results.
  #
  scope :with_visits, lambda {
    select(
      'email_deliveries.*, ' +
      'IFNULL(rv.count, 0) repeat_visits, ' +
      'IFNULL(nv.count, 0) new_visits').
    joins(
      'LEFT OUTER JOIN ( ' +
      'SELECT COUNT(DISTINCT session) count, campaign_id nv_cid ' +
      'FROM page_views ' +
      'WHERE page_views.new_visit = 1 ' +
      ' GROUP BY nv_cid ) nv ' + 
      'ON nv.nv_cid = email_deliveries.campaign_id').
    joins(
      'LEFT OUTER JOIN ( ' +
      'SELECT COUNT(DISTINCT session) count, campaign_id rv_cid ' +
      'FROM page_views ' +
      'WHERE page_views.new_visit = 0 ' +
      ' GROUP BY rv_cid ) rv ' +
      'ON rv.rv_cid = email_deliveries.campaign_id')
  }

  class << self
    def deliver!(id, opts={})
      find(id).deliver!(opts)
    end

    def deliver_with_queue!(id, opts={})
      deliver! id, opts.merge(:skip_queue => true)
    end

    # `new`, with defaulting attributes from the passed parent `email`
    def prepare(options={})
      new(options).tap do |record|
        if email = record.email
          options.reverse_merge! email.copy_attributes(:for_delivery => true)
        end

        record.attributes = options
      end
    end
  end

  delegate :sub_type, :name, :to => :email, :allow_nil => true

  def deliver!(opts={})
    return false unless persisted?

    unless opts.delete(:skip_queue)
      self.class.deliver_with_queue!(id, opts)
      false
    else
      if email.present?
        email.from      = from      if from.present?
        email.reply_to  = reply_to  if reply_to.present?
        email.subject   = subject   if subject.present?
        email.html_body = html_body if html_body.present?
        email.text_body = text_body if text_body.present?

        recipients = email.send!(target, {
          :skip_queue => true, 
          :campaign => campaign
        })

        update_attributes(
          :requests   => recipients,
          :recipients => recipients.to_s
        )
      else
        Rails.logger.error("EmailDelivery #{id} attempted delivery without attached email")
        false
      end
    end
  end

  # contact_ids only gets set if it's an array or a properly formatted string
  def contact_ids=(val)
    write_attribute :contact_ids, begin
      case val
      when String  then val.delete(' ')
      when Array   then val.flatten.join(',')
      when Integer then val.to_s
      else ''
      end
    end

    # clear user_ids cache
    @user_ids = nil

    contact_ids
  end

  def contact_ids
    (read_attribute(:contact_ids) || '').split(',').map(&:to_i)
  end

  def contacts_scope
    Contact.where(:id => contact_ids)
  end

  def user_ids 
    empty_unless_contact_ids { User.connection.send(:select_values, users.select('users.id').to_sql, 'User ID Load') }
  end

  def contacts
    empty_unless_contact_ids { contacts_scope }
  end

  def users
    empty_unless_contact_ids { User.joins(:contact).merge(contacts_scope) }
  end

  attr_reader :campaign_code

  def campaign_code=(value)
    if value.present?
      if existing_campaign = EmailCampaign.find_by_code(value)
        self.campaign = existing_campaign
      else
        self.campaign = EmailCampaign.new(:code => value, :name => "Campaign #{value}")
      end
    else
      self.campaign = nil
    end

    @campaign_code = value
  end
  delegate :code, :to => :campaign, :prefix => true, :allow_nil => true

  protected

  def target
    if users.blank?
      nil
    elsif email && email.sub_type.newsletter?
      users
    else
      users.primary
    end
  end

  def empty_unless_contact_ids
    contact_ids.present? ? yield : []
  end

  def html_body
    read_attribute(:html_body) || ''
  end

  def text_body
    read_attribute(:text_body) || ''
  end

  def prepare_bodies
    # TODO is this a bug?  This happens on UserEmail, shouldn't happen here?
    if email.sub_type.crm_template? && text_body.present?
      body_with_links = auto_link(text_body.dup, :html => { :rel => 'external nofollow' }, :sanitize => false, :link => :urls)
      self.html_body = simple_format(body_with_links, {}, :sanitize => false)
    end

    self.text_body = append_link_variables(TEXT_VARIABLE_SUB_REGEX, text_body)
    self.html_body = append_link_variables(HTML_VARIABLE_SUB_REGEX, html_body)
  end

  def append_link_variables(regex, text)
    text.gsub(regex) do |match|
      "#{match}#{$1 ? '&' : '?'}#{link_query_variables}"
    end
  end

  def link_query_variables
    # NOTE uid is substituted in the sendgrid merge and campaign.code
    #      is substituted at the liquid render
    retv =  "#{E9Crm.query_user_id}=#user_id#"
    retv << "&#{E9Crm.query_param}={{campaign.code}}" if campaign
  end
end
