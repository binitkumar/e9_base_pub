class UserEmail < Email
  include E9::HTML # for converting text emails to HTML

  include E9::ActiveRecord::Initialization

  self.sub_types = %w(newsletter crm_template lead_nourishing)

  validates :html_body, :text_body, :presence => { :if => lambda {|m| m.sub_type.newsletter?  } }
  validates :subject, :presence => true
  validate { errors.add(:sub_type, :inclusion) unless UserEmail.sub_types.include?(sub_type) }

  before_validation :ensure_default_fields 
  before_save :ensure_mailing_list
  before_save :prepare_bodies

  def send!(*args)
    opts = args.extract_options!

    super(*args, opts).tap do |result|
      if !opts[:test] && result && sub_type.newsletter?
        # stolen from rails 3.1 update_column, which updates the column 
        # without saving
        self.active = false
        self.class.update_all({:active => false}, self.class.primary_key => id) == 1
      end
    end
  end

  def list_managed?
    sub_type.blank? || sub_type.newsletter?
  end

  def plain_text?
    !list_managed? && text_body.present?
  end

  protected

    def prepare_bodies
      if plain_text?
        body_with_links = auto_link(text_body.dup, :html => { :rel => 'external nofollow' }, :sanitize => false, :link => :urls)
        self.html_body = simple_format(body_with_links, {}, :sanitize => false)
      end
    end

    def ensure_mailing_list
      self.mailing_list ||= MailingList.default
    end

    def ensure_default_fields
      self.sub_type = read_attribute(:sub_type).presence || self.class.sub_types.first

      if sub_type.newsletter?
        self.html_body = html_body.presence || E9::Config[:default_html_email]
        self.text_body = text_body.presence || E9::Config[:default_text_email]
      end
    end

    def _assign_initialization_defaults
      ensure_default_fields
    end

end
