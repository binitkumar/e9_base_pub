require 'spec_helper'

describe Favorite do
  before do
    @user  = Factory(:user)
    @page  = Factory(:page)
    @topic = Factory(:topic)
    @favorites = []
    @favorites << Favorite.new(:favoritable => @page)
    @favorites << Favorite.new(:favoritable => @topic)
    @user.favorites = @favorites
    @user.reload
  end
  it { @user.favorites.length.should == @favorites.length }
  it { @user.favorites.map(&:favoritable).should == [@page, @topic] }
  it { Topic.favorited_by(@user).should == [@topic] }
  it { Page.favorited_by(@user).should == [@page] }
  it { @page.favoriters.should == [@user] }
  it { @topic.favoriters.should == [@user] }
end
