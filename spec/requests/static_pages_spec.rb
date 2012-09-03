require 'spec_helper'

describe "StaticPages" do

subject{page}

  shared_examples_for "all static pages" do
    it {should have_selector('h1', text: heading)}
    it {should have_selector('title', text: full_title(page_title))}
  end

  describe "Home page" do
    before{visit root_path}
      let(:heading) {'Sample App'}
      let (:page_title) {''}

      it_should_behave_like "all static pages"
      it {should_not have_selector('title', text: "| Home")}

      describe "for signed-in users" do
        let(:user) {FactoryGirl.create(:user)}

        before do
          FactoryGirl.create(:micropost, user: user, content: "Loren ipsum")
          sign_in user
          visit root_path          
        end

        it "should show sidebar's microposts counter for one single micropost" do
          page.should have_content("1 micropost")
        end

        it "should welcome the signed-in user" do
          page.should have_selector("h1", text: user.name)
        end
          
        it "should render user's feed" do
          user.feed.each do |item|
            page.should have_selector("li##{item.id}", text: item.content)
          end          
        end

        describe "for signed-in users with more than one micropost" do
          let(:active_user) {FactoryGirl.create(:user)}
          before do
            31.times{FactoryGirl.create(:micropost, user: active_user, content: "Loren ipsum")}
            sign_in active_user
            visit root_path
          end

          it "should show properly sidebar's microposts counter for more than one micropost(pluralize)" do
            page.should have_content("#{active_user.microposts.count} microposts")
          end

          it "should paginate when user has more than 30 micropost" do
            page.should have_selector ('div.pagination')
          end
        end

        describe "followers/following counts" do
          let(:other_user) {FactoryGirl.create(:user)}
          before do
            other_user.follow!(user)
            visit root_path
          end

          it{should have_link("0 following", href: following_user_path(user))}
          it{should have_link("1 followers", href: followers_user_path(user))}
        end
      end
  end

  describe "Help page" do
    before {visit help_path}
      let(:heading) {'Help'}
      let (:page_title) {'Help'}
      it_should_behave_like "all static pages"
  end

  describe "About page" do
    before {visit about_path}
      let(:heading) {'About'}
      let (:page_title) {'About Us'}
      it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before {visit contact_path}
      let(:heading) {'Contact'}
      let (:page_title) {'Contact'}
      it_should_behave_like "all static pages"
  end

  it "should have the right links in the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Home"
    page.should have_selector 'title', text: full_title('')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
  end
end