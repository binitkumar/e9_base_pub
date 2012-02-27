require 'spec_helper'

describe Region do
  before(:each) do
    @region = Factory(:region)
    @region.should be_valid
  end

  describe 'accepting nested attributes for nodes' do
    before(:each) do
      @nodes = [Factory(:node_with_snippet), Factory(:node_with_partial)]
      @nodes_attributes = {
        '0' => { :renderable_id => @nodes[0].renderable_id },
        '1' => { :renderable_id => @nodes[1].renderable_id }
      }
      @region.nodes.count.should == 0
      @region.attributes = { :nodes_attributes => @nodes_attributes }
      @region.save && @region.reload
    end

    it 'should accept new nodes as nested attributes' do
      @region.nodes.count.should == 2
    end

    it 'should position them according to position received' do
      @region.nodes[0].position.should == 1
      @region.nodes[0].renderable.should == @nodes[0].renderable

      @region.nodes[1].position.should == 2
      @region.nodes[1].renderable.should == @nodes[1].renderable
    end

    it 'should destroy a node when being passed _destroy' do
      @nodes = @region.nodes
      @nodes_attributes = {
        '0' => { :id => @nodes[1].id, :renderable_id => @nodes[1].renderable_id, :_destroy => '1' },
        '1' => { :id => @nodes[0].id, :renderable_id => @nodes[0].renderable_id }
      }
      @region.attributes = { :nodes_attributes => @nodes_attributes }
      @region.save && @region.reload
      @region.nodes.count.should == 1
    end
  end

  describe 'in a view' do
    describe 'of a page' do
      before(:each) do
        @region = Factory(:region_in_page)
        @region.should be_valid
        @region.view_type.should == "ContentView"
      end

      it 'should not pass protected attributes when copying' do
        copy = @region.copy
        copy.view_type.should be nil
        copy.view_id.should be nil
      end
    end

    describe 'of a layout' do
      before(:each) do
        @region = Factory(:region_in_layout)
        @region.should be_valid
        @region.view_type.should == "Layout"
      end

      it 'should not pass protected attributes when copying' do
        copy = @region.copy
        copy.view_type.should be nil
        copy.view_id.should be nil
      end
    end
  end

  describe 'having nodes' do
    before(:each) do
      # NOTE for whatever reason, acts_as_nested_set needs a reload after creation
      @region_type = Factory(:region_type)
      @snippets = Array.new(2) { Factory(:snippet, :region_types => [@region_type]) }
      @region = Factory(:region, :region_type => @region_type)
      @region.add_renderables!(@snippets)
      @region.nodes.count.should == 2
      @region.should be_valid
    end
    it 'should pass all descendents when copying' do
      copy = @region.copy!
      copy.reload
      copy.nodes.count.should == @region.nodes.count
      copy.nodes.map(&:renderable_id).should == @region.nodes.map(&:renderable_id)
    end
  end
end
