class Admin::QuestionsController < Admin::ContentController
  include E9::Controllers::Sortable

  belongs_to :faq

  respond_to :html, :js
  carrierwave_column_methods :thumb, :context => :admin
  
  before_filter :add_faqs_breadcrumb
  add_resource_breadcrumbs

  use_tiny_mce :only => [:show, :edit, :create, :new]

  def index
    index! do |format|
      # NOTE why is the default responder not rendering the js template by default?
      format.html
      format.js
    end
  end

  def create;  create!  { parent_path } end
  def update;  update!  { parent_path } end
  def destroy 
    destroy! do |format|
      format.html { redirect_to parent_path } 
    end
  end

  protected 

  ##
  # IR
  #
  def collection 
    @questions ||= end_of_association_chain.order(:position).all
  end

  def build_resource
    # NOTE we can't use end_of_association_chain here because the form allows you to change parents
    @question ||= Question.new(params_for_build)
  end

  def params_for_build
    (params[:question] || {}).reverse_merge(
      :faq_id       => parent.try(:id), 
      :published_at => DateTime.now,
      :author       => current_user
    )
  end

  ##
  # filters
  #
  def add_faqs_breadcrumb
    add_breadcrumb e9_t(:index_title, :scope => :"admin.faqs", :resource_class => Faq), :admin_faqs_path
  end

  def add_index_breadcrumb
    add_breadcrumb e9_t(:show_title, :scope => :"admin.faqs", :model => parent.title), admin_faq_questions_path(parent)
  end

  ##
  # helpers
  #
  def parent_path
    # resources are created assuming they belong to a faq, which is reflected
    # in the url for the form, but the faq_id may also be set in the form and change
    # so reload and check the resource for the parent before falling back
    # to the original parent determined from the url params
    p = resource.reload.faq || parent rescue parent
    p ? admin_faq_questions_path(p) : admin_faqs_path
  end
end
