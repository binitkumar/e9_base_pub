class BannersController < ApplicationController
  inherit_resources
  actions :show

  respond_to :json

  def show
    respond_to do |format|
      format.html { render_404 }
      format.json { render :json => resource }
    end
  end
end
