require 'spec_helper'

describe ShareSite do
  #context "bad urls" do
    #before { @bad_urls = %w(htp://somebadurl.com asdfqwer http://^_^.yay.com) }
    #it "should not be valid" do
      #@bad_urls.each do |bad|
        #@share_site = Factory.build(:share_site, :url => bad)
        #@share_site.should_not be_valid
        #@share_site.errors[:url].should_not be_blank
      #end
    #end
  #end

  it "should add a liquid uri_escape on any page attr that doesn't start with 'url'" do
    @unfiltered_str = "http://bananas.com?w={{ current_page.whatevs }}&url={{ current_page.url }}&umm={{ current_page.umm }}"
    @filtered_str = "http://bananas.com?w={{ current_page.whatevs | uri_escape }}&url={{ current_page.url }}&umm={{ current_page.umm | uri_escape }}"
    @share_site = Factory.build(:share_site, :url => @unfiltered_str)
    @share_site.send(:filtered_url).should == @filtered_str
  end
end
