require 'spec_helper'

describe Forum do
  before { @forum = Factory(:forum) }
  it { @forum.should be_valid }

  it "should generate a permalink like id-title" do
    @forum = Factory(:forum, :title => "slug-safe-title")
    @forum.permalink.should == "#{@forum.id}-#{@forum.title}"
  end
end
