require 'spec_helper'

describe Page do
  it { Factory.build(:page).should be_valid }

  describe "with content" do
    before(:each) do
      @page = Factory(:page_with_content)
    end

    it "should destroy its children when destroyed" do
      @page.should have(2).regions
      Page.destroy_all
      Region.count.should be 0
    end
  end
  
  it "should be unpublished by default" do
    @page = Factory(:page)
    @page.should_not be_published
    @page.should_not be_previously_published
  end

  describe "should publish (and notify) if published" do
    before do
      @page = Factory.build(:page, :published => true)
      # NOTE This fails on mock receiving unexpected msg :update, with :after_publish, @page
      #observer = mock('observer')
      #observer.should_receive(:update).with(:after_publish, @page).at_least(:once)
      #Page.add_observer(observer)
      @page.save
    end
    it { @page.should be_previously_published }
    it { @page.published_at.should_not be_nil }
  end

  describe 'slugs!' do
    it "should not be valid if the title is a system slug" do
      @page = Factory.build(:page)
      %w(users admin sign_in).each do |system_slug|
        @page.title = system_slug
        @page.should_not be_valid
        @page.errors[:title].should_not be_blank
      end
    end
  end

  describe 'setting published_at' do
    before do
      @yesterday = Date.today - 1.day
      @yesterday_noon = @yesterday.to_datetime + 12.hours
      @today = Date.today
      @today_noon = @today.to_datetime + 12.hours

      # start all tests with a page published yesterday (which will take the Time of now)
      @page = Factory.build(:page)
    end
  end

  it 'should delegate permalink errors to title' do
    #Factory(:user_page, :title => "asdf asdf")
    #@page = Factory.build(:user_page, :title => "asdf*asdf")

    #@page.should_not be_valid
    #@page.errors[:title].should_not be_blank
    #@page.errors[:permalink].should be_blank
  end

  describe 'accepting nested attributes for regions' do
    it 'should work' do
      @page = Factory(:page_with_content)
      @page.should have(2).regions

      @page.regions.each {|r| r.nodes.clear }
      @page.save && @page.reload

      region_ids = @page.regions.map(&:id)

      @renderables = [ Factory(:snippet), Factory(:snippet) ]
      renderable_ids = @renderables.map(&:id)

      @attrs = {
        :regions_attributes => {
          "0"=>{"id"=>region_ids[0], "nodes_attributes"=>{"0"=>{"renderable_id"=>renderable_ids[0] }}},
          "1"=>{"id"=>region_ids[1], "nodes_attributes"=>{"0"=>{"renderable_id"=>renderable_ids[1] }}}
        }
      }

      @page.attributes = @attrs
      @page.save
      @page.regions.each {|r| r.save }
      @page.reload

      @page.regions.count.should == 2
      @page.regions.map(&:nodes).flatten.map(&:renderable_id).should == renderable_ids
    end
  end
end
