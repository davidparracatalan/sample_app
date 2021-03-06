  require 'spec_helper'

describe "Authentication" do

  subject{ page }

  describe "signin page" do
    before {visit signin_path}        

    it {should have_selector('h1',     text: 'Sign in')}
    it {should have_selector('title',  text: 'Sign in')}

  end

  describe "signin" do
  before {visit signin_path}

    describe "with invalid information" do
      before {click_button "Sign in"}

      it {should have_selector('title',  text: 'Sign in')}
      it {should have_selector('div.alert.alert-error', text: 'Invalid')}            
    end

    describe "with valid information" do
      let(:user) {FactoryGirl.create(:user)}
      before {sign_in user}

      it{should have_selector('title', text: user.name)}
      it{should have_link('Profile', href: user_path(user))}
      it{should have_link('Settings', href: edit_user_path(user))}
      it{should have_link('Sign out', href: signout_path)}
      it{should_not have_link('Sign in', href: signin_path)}

      describe "followed by signout" do
        before { click_link "Sign out" }
        it {should have_link('Sign in') }
        it {should_not have_link('Profile')}
        it {should_not have_link('Settings')}
      end
    end

    describe "after visiting another page" do
      before {click_link "Home"}
      it {should_not have_selector('div.alert.alert-error')}
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) {FactoryGirl.create(:user)}

      describe "when attempting to access a protected page" do

        describe "in the Micropost controller" do
          describe "submitting the create action" do
            before {post microposts_path}
            specify {response.should redirect_to(signin_path)}
          end
          describe "submitting the destroy action" do
            before {delete micropost_path(FactoryGirl.create(:micropost))}
            specify {response.should redirect_to(signin_path)}
          end
        end

        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signin in" do
          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end

          describe "when signing in again" do
            before do
              visit signin_path
              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end

            it "should render the (default profile page)" do
              page.should have_selector('title', text:user.name)
            end
          end
        end
      end

      describe "in the users controller" do
        let(:user) {FactoryGirl.create(:user)}

        describe "visiting the edit page" do
          before {visit edit_user_path(user)}
          it {should have_selector('title', text: 'Sign in')}
        end

        describe "submitting the update action" do
          before {put user_path(user)}
          specify {response.should redirect_to(signin_path)}
        end

        describe "visiting the user index" do
          before {visit users_path}
          it{should have_selector('title', text: "Sign in")}
        end
      end

      describe "in the Relationships controller" do
        describe "submitting a relationship create" do
          before {post relationships_path}
          specify {response.should redirect_to (signin_path)}
        end

        describe "submitting a relationship destroy" do
          before {delete relationship_path(1)}
          specify {response.should redirect_to (signin_path)}
        end
      end
    end

    describe "as wrong user" do
      let(:user) {FactoryGirl.create(:user)}
      let(:wrong_user) {FactoryGirl.create(:user, email: "wronguser@example.com")}
      before {sign_in user}

      describe "visitting Users#edit page" do
        before {visit edit_user_path(wrong_user)}
        it {should_not have_selector('title', text: full_title('Edit user'))}
      end

      describe "submitting a PUT request to de Users#update action" do
        before {put user_path(wrong_user)}
        specify {response.should redirect_to(root_path)}
      end

    end
  end

  describe "as a non-admin user" do
    let(:user) {FactoryGirl.create(:user)}
    let(:non_admin_user) {FactoryGirl.create(:user)}

    before{sign_in non_admin_user}

    describe "submitting a DELETE request to Users#destroy action" do
      before{delete user_path(user)}
      specify{response.should redirect_to(root_path)}       
    end
  end

  describe "as an admin user" do
    let(:admin_user) {FactoryGirl.create(:admin)}

    before{sign_in admin_user}
    describe "submitting a DELETE request to Users#destroy action on the admin itself" do
      before{delete user_path(admin_user)}
      specify{response.should redirect_to(root_path)}
    end
  end
end