class EventRegistration < ActiveRecord::Base
  belongs_to :event_transaction
  belongs_to :event
  belongs_to :user

  include E9::ActiveRecord::InheritableOptions
  self.options_column = :details

  money_columns :paid

  attr_accessor :newsletter_optin

  before_create :find_or_create_user, 
                :assign_user_to_mailing_list_if_opted_in,
                :update_contact

  validates :name,  :presence   => true
  validates :email, :email      => { :allow_blank => true }, 
                    :presence   => true, 
                    :uniqueness => { :scope => :event_id }

  scope :cancelled, lambda {|v=true| where(:cancelled => v) }
  scope :attended, lambda {|v=true| where(:attended => v) }
  scope :by_transaction, lambda {|v| 
    joins(:event_transaction).merge EventTransaction.where(:transaction_id => v)
  }

  def paid
    Money.new(read_attribute(:paid).presence || 0)
  end

  def to_liquid
    Drop.new(self)
  end

  def role
    'administrator'.role
  end

  delegate :campaign_name, :transaction_id, 
      :to => :event_transaction, :allow_nil => true

  def details_as_markdown
    options.to_hash.map do |k, v| 
      next if v.blank?
      v = v.join(', ') if v.is_a?(Array)
      "**%s:**\n%s\n\n" % [k.to_s.titleize, v] 
    end.compact.join
  end

  def as_json(options={})
    { 
      :id         => id,
      :email      => email,
      :name       => name,
      :paid       => paid,
      :promo_code => promo_code
    }
  end

  def contact
    return nil unless user.present?

    unless user.contact.present?
      user.create_contact_if_missing!
      user.reload
    end

    user.contact
  end

  protected

    def find_or_create_user
      self.user = User.find_by_email(email) || begin
        args = {:email => email, :first_name => name}

        if options.respond_to?(:last_name) && options.last_name.present?
          args[:last_name] = options.last_name
        end

        User.prospects.create(args)
      end
    end


    def assign_user_to_mailing_list_if_opted_in
      if E9.true_value? newsletter_optin
        user.mailing_list_ids |= [MailingList.default]
      end
    end

    def update_contact
      if contact.present?
        info = contact.info || ''
        info += <<-INFO
\n----------------------
**Event:** #{event.try :title}

**Voucher #:** #{promo_code}

        INFO
        info += details_as_markdown
        contact.info = info

        if event.event_type
          contact.merge_tags([event.event_type.permalink])
        end
        
        contact.save
      end
    end

  class Drop < E9::Liquid::Drops::Base
    source_methods :email, :name, :promo_code, :options

    # this is called if the class doesn't respond to the method
    def before_method(method)
      @object.options.send(method)
    end

    def paid
      @object.try(:paid) && @object.paid.format
    end
  end
end
