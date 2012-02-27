require 'spec_helper'

describe ProfilesController do
  context 'as a user' do
    before do
      @user = Factory(:user)
      request.env['warden'] = mock_warden(@user)
    end
    context "GET show" do
      context "default" do
        before { get :show }
        it { response.should be_success }
        it("should render show template") { response.should render_template :show }
        it("should show the logged in user's profile") { assigns(:user).should be @user}
      end

      # NOTE favorites now handled in ajax partial
      #context "having favorites" do
        #before do
          #5.times { @user.favorites << Favorite.new(:favoritable => Factory(:page)) }
          #5.times { @user.favorites << Favorite.new(:favoritable => Factory(:topic)) }
          #get :show
        #end
        #it { assigns(:favorited_topics).each {|fav| fav.favoritable.should be_an_instance_of(Topic) } }
        #it { assigns(:favorited_pages).each {|fav| fav.favoritable.should be_an_instance_of(Page) } }
        #it { assigns(:favorited_topics).map(&:id).should == @user.favorites.of_type('Topic').limit(3).map(&:id) }
        #it { assigns(:favorited_pages).map(&:id).should == @user.favorites.of_type('Page').limit(3).map(&:id) }
        #it { assigns(:favorited_topic_count).should == 5 }
        #it { assigns(:favorited_page_count).should == 5 }
        #it { assigns(:favorited_topics).length.should == 3 }
        #it { assigns(:favorited_pages).length.should == 3 }
      #end

      # NOTE 'commented on' now handled in ajax partial
      #context "having commented" do
        #before do
          #5.times { @user.comments << Factory.build(:comment, :commentable => Factory(:page)) }
          #5.times { @user.comments << Factory.build(:comment, :commentable => Factory(:topic)) }
          #get :show
        #end
        #it { assigns(:commentables).length.should == 3 }
        #it { assigns(:commentables_count).should == 10 }
      #end
    end
    context "GET edit" do
      before { get :edit }
      it { response.should be_success }
      it('should render the edit template') { response.should render_template :edit }
    end
    context "PUT update" do
      context "with valid params" do
        before { post :update, :user => Factory.attributes_for(:user) }
        it { response.should redirect_to profile_path }
        it { flash[:notice].should_not be_empty }
      end
    end
  end
end
