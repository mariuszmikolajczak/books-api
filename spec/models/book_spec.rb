require "rails_helper"

RSpec.describe Book, type: :model do
  subject { build(:book) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:serial_number) }
    it { is_expected.to validate_uniqueness_of(:serial_number) }
    it { is_expected.to validate_numericality_of(:serial_number).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[available borrowed archived]) }
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "defaults status to available" do
    expect(Book.new.status).to eq("available")
  end
end
