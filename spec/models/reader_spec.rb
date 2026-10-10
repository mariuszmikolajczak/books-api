# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reader, type: :model do
  subject(:reader) { build(:reader) }

  describe "factory" do
    it "builds a valid reader" do
      expect(reader).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:card_number) }
    it { is_expected.to validate_numericality_of(:card_number).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }

    describe "email uniqueness" do
      subject(:reader) { create(:reader) }

      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

      it "rejects a duplicate that differs only by case and whitespace" do
        duplicate = build(:reader, email: "  #{reader.email.upcase}  ")

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:email]).to include("has already been taken")
      end
    end

    describe "email format" do
      %w[joe@example.com joe.doe+tag@sub.example.pl].each do |email|
        it "accepts #{email}" do
          expect(build(:reader, email:)).to be_valid
        end
      end

      ["plainaddress", "@example.com", "jan@", "joe doe@example.com"].each do |email|
        it "rejects #{email.inspect}" do
          reader = build(:reader, email:)

          expect(reader).not_to be_valid
          expect(reader.errors[:email]).to be_present
        end
      end
    end
  end

  describe "normalization" do
    it { is_expected.to normalize(:email).from("  Joe@Example.COM ").to("joe@example.com") }
    it { is_expected.to normalize(:full_name).from("  Joe   Doe ").to("Joe Doe") }
  end
end
