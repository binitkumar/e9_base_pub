class E9Crm::LeadsController < ApplicationController
  # NOTE this controller, contrary to sanity, doesn't handle admin/crm/leads,
  #      rather it handles only public side lead creation

  # TODO these should all be included in e9_base
  include E9::Helpers::Title
  include E9::Helpers::Translation
  include E9::Helpers::ResourceErrorMessages

  before_filter :find_campaign_or_default_offer, 
        :only => :campaign_or_default_offer_lead_redirect

  # NOTE it's necessary to call association_chain before the checkbox
  # captcha is included, as the views require @offer, and the
  # checkbox captcha halts returns from the process
  before_filter :association_chain
  include E9::Controllers::CheckboxCaptcha

  inherit_resources
  belongs_to :offer, :param => :public_offer_id
  defaults :resource_class => Deal, :instance_name => 'deal'

  # force no responder for html
  respond_to :html, :only => []
  respond_to :js,   :only => [:create]
  respond_to :json, :only => [:new, :create]

  has_scope :leads, :type => :boolean, :default => true

  # we want to control (or not use) our own flash messages
  skip_after_filter :flash_to_headers

  after_filter :install_offers_cookie, :only => :create

  #
  # In the case that this is actually an HTML request, redirect to
  # the offer on success (regardless of what type of offer?)
  #
  def create
    object = build_resource

    create!(:flash => false) do |success, failure|
      success.html { redirect_to public_offer_path(@offer) }
      success.json { render :json => DealDecorator.new(object) }
      success.js
    end
  end

  def new
    object = build_resource

    new! do |format|
      format.html
      format.json { render :json => DealDecorator.new(object) }
    end
  end

  def index
    index! do
      format.json do 
        render :json => {
          :offers => tracking_campaign
        }
      end
    end
  end

  # GET /offer
  def campaign_or_default_offer_lead_redirect
    redirect_to new_public_offer_deal_path(@offer)
  end

  protected

  def find_campaign_or_default_offer
    @offer = begin
      if tracking_campaign.respond_to?(:offer)
        offer = tracking_campaign.offer
      end

      offer ||= Offer.default
    end
  end

  def create_resource(object)
    @lead_was_created = object.save
  end

  def build_resource
    get_resource_ivar || set_resource_ivar(
      # NOTE mailing list ids come from the form (to allow opt-outs)
      Deal.leads.new((params[resource_instance_name] || {}).reverse_merge(
        :user             => current_user,
        :offer            => @offer,
        :campaign         => tracking_campaign
      ))
    )
  end

  #
  # this cookie is installed after successfully creating a lead and once installed,
  # allows the cookied user to view the public offer page for the parent @offer
  #
  def install_offers_cookie 
    if @lead_was_created
      if tracking_cookie.user.blank? && resource.effective_user
        tracking_cookie.update_attribute(:user_id, resource.effective_user.id)
      end

      cookied_offer_array = Marshal.load(cookies['_e9_offers']) rescue []
      cookied_offer_array |= [@offer.id]

      cookies['_e9_offers'] = {
        :value   => Marshal.dump(cookied_offer_array),
        :expires => 1.year.from_now
      }
    end
  end

  def determine_layout
    request.xhr? ? false : super
  end

  def find_current_page
    @current_page ||= Offer.page || super
  end
end
