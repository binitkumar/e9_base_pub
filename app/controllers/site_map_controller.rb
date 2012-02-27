class SiteMapController < ApplicationController
  layout false
  respond_to :xml

  def index
    @results = Array.new.tap do |results|
      results.concat ContentView.site_mappable.all
      results.concat Category.site_mappable.all
    end

    respond_with(@results)
  end

end
