require 'spec_helper'

module FactoryHelper
  def factory(klass, opts = {})
    Factory(:"#{klass.model_name.element}", opts)
  end
end

describe Search do
  include FactoryHelper

  before do
    @searchables = Search::Searchables
    @searchables.each do |s|
      s.stub!(:search).and_return([])
    end
  end

  specify "Searchables should all implement search" do
    @searchables.length.should be > 2
    @searchables.each {|klass| klass.should respond_to(:search) }
  end

  context "searching twice" do
    before do
      @search1, @search2 = Factory(:search), Factory(:search)
    end
    it "should count searches" do
      @search1.search_count.should == 1
      @search2.search_count.should == 2
    end
  end

  context "given some searchables" do
    before do
      @s1, @s2 = @searchables[0, 2]
      @s1.stub!(:search).and_return([factory(@s1), factory(@s1)])
      @s2.stub!(:search).and_return([factory(@s2)])

      @search = Factory(:search)
    end
    it { @search.results_count.should == 3 }
    it { @search.search_count.should == 1 }
    it { @search.results.length.should == 3 }
    it { @search.results_by_class.length.should == 2 }
    it { @search.results_by_class[0][0].should == @s1 }
    it { @search.results_by_class[0][1].length.should == 2 }
    it { @search.results_by_class[1][0].should == @s2 }
    it { @search.results_by_class[1][1].length.should == 1 }
  end

end
