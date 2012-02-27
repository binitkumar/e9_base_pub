class FavoritesController < ApplicationController
  inherit_resources
  actions :index, :create, :destroy

  # TODO what is the proper way to handle pages that do not respond_to HTML?
  # respond_to wants to simply return a head 406, but that's not exactly user friendly on error.
  clear_respond_to
  respond_to :js
  respond_to :html, :except => :index

  before_filter :authenticate_user!

  has_scope :of_type, :only => :index
  has_scope :order, :default => 'created_at DESC', :only => :index

  def index
    index! do |format|
      format.html { render_404 }
    end
  end

  def create
    create! do |format|
      format.html { redirect_to(resource.favoritable) }
      format.js { render 'toggle_favorite' }
    end
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to(resource.favoritable) }
      format.js { render 'toggle_favorite' }
    end
  end

  protected

  def build_resource
    @favorite ||= end_of_association_chain.send(method_for_build, params[:favorite])
  end

  def begin_of_association_chain
    current_user
  end

  def pagination_per_page_default
    E9::Config[:home_records_per_page]
  end

  def collection
    @favorites ||= begin
      @favorite_type = params[:of_type].classify.constantize rescue nil

      scope = end_of_association_chain.valid.for_roleable(current_user)

      WillPaginate::Collection.create(1, pagination_parameters[:per_page], scope.count) do |pager|
        scope = scope.limit(pagination_parameters[:per_page])
        scope = scope.offset(params[:offset]) if params[:offset]
        pager.replace(scope.to_a)
      end
    end
  end

  def build_resource
    @favorite ||= begin
      klass       = params[:favorite][:favoritable_type].classify.constantize
      favoritable = klass.find(params[:favorite][:favoritable_id])
      end_of_association_chain.send(method_for_build, :favoritable => favoritable)
    rescue
      raise ActiveRecord::RecordNotFound
    end
  end

end
