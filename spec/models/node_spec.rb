require 'spec_helper'

describe Node do
  describe 'with renderable' do
    describe 'snippet' do
      before(:each) do
        @node = Factory(:node_with_snippet)
        @node.renderable.should be_a_kind_of Renderable
        @node.should be_valid
      end

      it 'should be associated to a snippet' do
        @node.renderable.should be_an_instance_of Snippet
      end
    end

    describe 'partial' do
      before(:each) do
        @node = Factory(:node_with_partial)
        @node.renderable.should be_a_kind_of Renderable
        @node.should be_valid
      end

      it 'should be associated to a menu' do
        @node.renderable.should be_an_instance_of Partial
      end
    end
  end
end
