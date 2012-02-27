class Admin::MailingListsController < Admin::ResourceController
  respond_to :html, :js

  include E9::Controllers::Orderable

  has_scope :newsletters, :default => true, :type => :boolean

  add_resource_breadcrumbs

  def create
    create! do |success, failure|
      success.html { redirect_to admin_mailing_lists_path }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to admin_mailing_lists_path }
    end
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to admin_mailing_lists_path }
    end
  end

  protected

  ##
  # Orderable
  #
  def default_ordered_on
    'name'
  end

  def default_ordered_dir
    'ASC'
  end

end
