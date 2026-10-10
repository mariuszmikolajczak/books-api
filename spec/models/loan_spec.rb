# frozen_string_literal: true

require "rails_helper"

RSpec.describe Loan, type: :model do
  subject { build(:loan) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:book) }
    it { is_expected.to belong_to(:reader) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:due_at) }
    it { is_expected.to validate_presence_of(:borrowed_at) }

    it "rejects due_at not after borrowed_at" do
      time = Time.zone.local(2026, 10, 10, 12, 0)
      loan = build(:loan, borrowed_at: time, due_at: time)

      expect(loan).not_to be_valid
      expect(loan.errors).to be_of_kind(:due_at, :after_borrowed_date)
    end
  end

  describe "one active loan per book" do
    let(:book) { create(:book) }

    it "rejects a second active loan for the same book" do
      create(:loan, book:)
      loan = build(:loan, book:)

      expect(loan).not_to be_valid
      expect(loan.errors[:book_id]).to include("is already borrowed")
    end

    it "allows a new loan once the previous one is returned" do
      create(:loan, :returned, book:)

      expect(build(:loan, book:)).to be_valid
    end

    it "allows an active loan for a different book" do
      create(:loan, book:)

      expect(build(:loan)).to be_valid
    end

    it "does not block saving a returned loan while the book is borrowed again" do
      old_loan = create(:loan, :returned, book:)
      create(:loan, book:)

      old_loan.due_at += 1.day
      expect(old_loan).to be_valid
    end

    it "lets the active loan itself be updated" do
      loan = create(:loan, book:)

      loan.due_at += 7.days
      expect(loan).to be_valid
    end
  end
end
