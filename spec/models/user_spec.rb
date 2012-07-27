# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean         default(FALSE)
#

require 'spec_helper'

describe User do
  before do
    @user=User.new(name: "testname", 
                   email: "testaddress@test_emailserver.test",
                   password: "testpassword",
                   password_confirmation: "testpassword")
  end
  
  subject{@user}

  it {should respond_to(:name)}
  it {should respond_to(:email)}
  it {should respond_to(:password_digest)}
  it {should respond_to(:password)}
  it {should respond_to(:password_confirmation)}
  it {should respond_to(:remember_token)}
  it {should respond_to(:admin)}
  it {should respond_to(:authenticate)}
  it {should respond_to(:microposts)}

  describe "accessible atributes" do
    it "should not access to admin atttribute" do
      expect do
        User.new(admin: true)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "with attribute admin set to true" do
    before {@user.toggle!(:admin)}
    it {should be_admin}

  end

  describe "when name is not present" do
    before {@user.name=""}
    it{should_not be_valid}
  end

  describe "when email is not present" do
    before {@user.email=""}
    it{should_not be_valid}
  end

  describe "when name is too long" do
    before {@user.name="a"*51}
    it{should_not be_valid}
  end

  describe "when e-mail format is invalid" do
    it "should not be invalid" do
      addresses = %w[user@example,com usuer_at_example.net user@example.]
      addresses.each do |invalid_address|
        @user.email=invalid_address
        @user.should_not be_valid
      end
    end
  end

  describe "when e-mail format is valid" do
    it "should be valid" do
      addresses=%w[user@ejemplo.com user_2@ejemplo.com user@ejemplo.co.uk 
                   user.dot@ejemplo.com user+user@server.org USer234@server.co.uk]
      addresses.each do |address|
        @user.email=address
        @user.should be_valid
      end
    end
  end

  describe "when e-mail address is already taken" do
    before do
        user_with_same_email = @user.dup
        user_with_same_email.email=@user.email.swapcase
        user_with_same_email.save
    end
      it {should_not be_valid}
  end

  describe "when password valule is empty" do
    before {@user.password=@user.password_confirmation=" "}
    it{should_not be_valid}
  end

  describe "when pasword and password confirmation don't match" do
    before {@user.password_confirmation="mismatch"}
    it{should_not be_valid}
  end

  describe "when the password is nil" do
    before{@user.password_confirmation=nil}
    it{should_not be_valid}
  end

  describe "wuth a password too short" do
    before{@user.password=@user.password_confirmation="a"*5}
    it{should be_invalid}
  end

  describe "return value of athenticate method" do
    before{@user.save}
    let(:found_user) {User.find_by_email((@user.email))}

    describe "with valid password" do
      it{should==found_user.authenticate(@user.password)}
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "remember token" do
    before {@user.save}
    its(:remember_token) {should_not be_blank}
  end

  describe "microposts association" do
    before {@user.save}

    let!(:older_micropost) {FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)}
    let!(:newer_micropost) {FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)}

    it "should have the right microposts in the right order" do
      @user.microposts.should==[newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts=@user.microposts
      @user.destroy
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "user's feed contains only user's microposts" do
      let(:unfollowed_post) {FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))}

      its(:feed) {should include(newer_micropost)}
      its(:feed) {should include(older_micropost)}
      its(:feed) {should_not include(unfollowed_post)}
    end
  
  end
end
