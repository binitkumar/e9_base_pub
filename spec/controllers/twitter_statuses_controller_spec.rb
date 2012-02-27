require 'spec_helper'

describe TwitterStatusesController do
  describe "POST create" do
    before do
      @message = "testing message"
      post :message => @message, :format => :json
    end
    it { assigns(:twitter_status).text.should == @message }
  end

  describe "DELETE destroy" do

  end

  describe "GET show" do

  end


end
