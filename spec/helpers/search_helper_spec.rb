require 'spec_helper'

describe SearchHelper do
  describe "excerpt_or_snippet" do
    before do
      @chars = "x" * 1000
      @substr = "asdf"

      @substr_in_text   = @chars
      @substr_in_text[500, @substr.length] = @substr

      @substr_head_text = @chars
      @substr_head_text[0, @substr.length] = @substr

      @substr_end_text  = @chars
      @substr_end_text[-@substr.length, @substr.length] = @substr
    end

    context "with no query" do
      it "should truncate to length if passed length" do
        @result = helper.excerpt_or_snippet(@chars, nil, 50)
        @result.length.should == 50
      end

      it "should truncate to config if not passed length" do
        @result = helper.excerpt_or_snippet(@chars, nil)
        @result.length.should == E9::Config[:feed_summary_characters]
      end
    end

    context "feed_summary" do
      it "should truncate to config if not passed length" do
        @result = helper.feed_summary_excerpt_or_snippet(@chars, nil)
        @result.length.should == E9::Config[:feed_summary_characters]
      end
    end

    context "title_summary" do
      it "should truncate to config if not passed length" do
        @result = helper.feed_title_excerpt_or_snippet(@chars, nil)
        @result.length.should == E9::Config[:feed_max_title_characters]
      end
    end
  end
end
