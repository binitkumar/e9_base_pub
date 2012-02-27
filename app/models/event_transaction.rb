class EventTransaction < ActiveRecord::Base
  belongs_to :event
  belongs_to :campaign

  delegate :gateway, :to => 'E9::ActiveMerchant'

  money_columns :total_paid

  composed_of :cc_date, :class_name => "Date"

  has_many :event_registrations
  accepts_nested_attributes_for :event_registrations, :allow_destroy => false
  has_record_attributes :event_registrations, :skip_name_format => true

  before_validation :ensure_event_registration_references

  before_validation :determine_total_paid, :on => :create

  before_create :validate_and_capture_payment
  before_create :generate_token

  def campaign_name
    campaign.try(:to_s)
  end

  def to_param
    token
  end

  def role
    'administrator'.role
  end

  # bunch of aliases which I should have just named the columns
  %w(first_name last_name number expire_year expire_month expire_date).each do |attr|
    class_eval("def card_#{attr}; cc_#{attr} end")
  end

  validate :on => :create do
    unless total_paid.zero?
      @cc = ::ActiveMerchant::Billing::CreditCard.new(
        :first_name         => cc_first_name,
        :last_name          => cc_last_name,
        :number             => cc_number,
        :month              => cc_expire_month,
        :year               => cc_expire_year,
        :verification_value => cc_cvv
      )

      unless @cc.valid?
        attr_map = {
          :first_name         => :cc_first_name,
          :last_name          => :cc_last_name,
          :number             => :cc_number,
          :month              => :cc_expire_month,
          :year               => :cc_expire_year,
          :verification_value => :cc_cvv
        }

        @cc.errors.each do |attr, errs|
          if attr = attr_map[attr.to_sym]
            errs.each {|err| errors.add(attr, :invalid, :message => "#{self.class.human_attribute_name(attr)} #{err}") }
          else
            errs.each {|err| errors.add(:base, :invalid, :message => "#{attr.titleize} #{err}") }
          end
        end
      end
    end
  end

  attr_reader :cc, :response
  attr_accessor :cc_cvv, :cc_number

  def cc_number=(v)
    unless v.nil?
      write_attribute :cc_number, v.sub(/.*(\d{4})$/, '************\1')
    end

    @cc_number = v
  end

  def cc_date=(date)
    self.cc_expire_year = date.year
    self.cc_expire_month = date.month
  end

  def cc_date
    if cc_expire_year && cc_expire_month
      Date.new(cc_expire_year, cc_expire_month)
    else
      Date.today
    end
  end

  def total_paid
    Money.new(read_attribute(:total_paid).presence || 0)
  end

  def to_liquid
    Drop.new(self)
  end

  protected

    def generate_token
      begin
        self.token = ActiveSupport::SecureRandom.hex(12)
      end until self.class.where(:token => self.token).count.zero?
    end

    def determine_total_paid
      self.total_paid = event_registrations.inject(Money.new(0)) do |mem, reg|
        mem + reg.paid
      end
    end

    class PaymentError < StandardError
    end

    def validate_and_capture_payment
      unless total_paid.zero?
        @response = gateway.authorize(total_paid.cents, @cc)

        unless @response.success?
          errors.add(:cc, nil, :message => @response.message)
          raise PaymentError, @response.message
        else
          begin
            response = gateway.capture(self.total_paid.cents, @response.authorization)

            self.transaction_id       = response.params['transaction_id']
            self.response_code        = response.params['response_code']
            self.response_reason_code = response.params['response_reason_code']
            self.response_reason_text = response.params['response_reason_text']
            self.avs_result_code      = response.params['avs_result_code']

            Rails.logger.debug("EventTransaction - Payment Successful - Transaction Id: #{self.transaction_id}")
          rescue => e
            Rails.logger.error("EventTransaction - Error Capturing Payment: #{e}")
            raise PaymentError, e.message
          end
        end
      end
    end

    def event_registrations_build_parameters
      { :event => self.event }
    end

    # fixes the issue of nested resources not being attached to their parent
    # association
    def ensure_event_registration_references
      event_registrations.each {|er| er.event_transaction = self }
    end

  class Drop < E9::Liquid::Drops::Base
    source_methods :transaction_id, :card_first_name, :card_last_name,
       :card_number, :card_expire_month, :card_expire_year, :card_expire_date

    def total_paid
      @object.try(:total_paid) && @object.total_paid.format
    end

    def registrations
      @object.event_registrations.map(&:to_liquid)
    end
  end
end
