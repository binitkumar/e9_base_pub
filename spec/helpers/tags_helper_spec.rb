require 'spec_helper'

describe TagsHelper do
  describe "tag list" do
    context "for resource with no tags" do
      before { @user_page = Factory(:user_page) }
      it { lambda { helper.tag_list(@user_page) }.should_not raise_error }
    end
    context "for resource with tags" do
      before do
        @user_page = Factory(:user_page)
        @user_page.set_tag_list_on("context1", "bunch,of,tags")
        @user_page.set_tag_list_on("context2", "some,more,tags")
        @user_page.save!
      end
      it { lambda { helper.tag_list(@user_page) }.should_not raise_error }
    end
  end
end
