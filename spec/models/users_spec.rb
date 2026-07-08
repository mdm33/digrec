require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.create(:user)).to be_valid
  end

  it "is invalid without login" do
    expect(FactoryBot.build(:user, login: nil)).not_to be_valid
  end

  it "is invalid without email" do
    expect(FactoryBot.build(:user, email: nil)).not_to be_valid
  end

  it "is invalid without first name or last name" do
    expect(FactoryBot.build(:user, first_name: nil)).not_to be_valid
    expect(FactoryBot.build(:user, last_name: nil)).not_to be_valid
  end

  it "has one or more roles" do
    u = FactoryBot.create(:user, role: 'reader')
    expect(u.has_role?(:reader)).to be_truthy
    expect(u.has_role?(:annotator)).to be_falsey
    expect(u.has_role?(:reviewer)).to be_falsey
    expect(u.has_role?(:administrator)).to be_falsey

    u.update_attributes!(role: 'annotator')
    expect(u.has_role?(:reader)).to be_truthy
    expect(u.has_role?(:annotator)).to be_truthy
    expect(u.has_role?(:reviewer)).to be_falsey
    expect(u.has_role?(:administrator)).to be_falsey

    u.update_attributes!(role: 'reviewer')
    expect(u.has_role?(:reader)).to be_truthy
    expect(u.has_role?(:annotator)).to be_truthy
    expect(u.has_role?(:reviewer)).to be_truthy
    expect(u.has_role?(:administrator)).to be_falsey

    u.update_attributes!(role: 'administrator')
    expect(u.has_role?(:reader)).to be_truthy
    expect(u.has_role?(:annotator)).to be_truthy
    expect(u.has_role?(:reviewer)).to be_truthy
    expect(u.has_role?(:administrator)).to be_truthy
  end
end
