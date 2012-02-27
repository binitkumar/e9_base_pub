class ImageMountsController < InheritedResources::Base
  include E9::Controllers::Sortable
  skip_after_filter :flash_to_headers, :except => :update_order

  belongs_to :banner, :optional => true

  respond_to :json
  respond_to :js, :only => :destroy
  respond_to :html, :only => [:edit, :reset]

  def temp
    new!
  end

  def reset
    object = resource
    object.reset!

    respond_to do |format|
      format.html { redirect_to object.url }
      format.js { 
        response.headers['Content-Location'] = image_mount_url(object)
        head 200
      }
    end
  end

  # NOTE successful updates don't return JSON content out of the box
  def update
    update! do |success, failure|
      success.json { render :json => resource }
    end
  end

  def destroy
    destroy! do |format|
      format.js { head 200 }
    end
  end
end
