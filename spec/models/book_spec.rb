# frozen_string_literal: true

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

    it "does not allow archiving a borrowed book" do
      book = create(:book, status: "borrowed")
      book.status = "archived"
      expect(book).not_to be_valid
      expect(book.errors[:base]).to include(I18n.t("activerecord.errors.models.book.borrowed_cannot_be_archived"))
    end
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "defaults status to available" do
    expect(Book.new.status).to eq("available")
  end

  it "formats serial number with leading zeros" do
    book = build(:book, serial_number: 42)
    expect(book.formatted_serial).to eq("000042")
  end
end

