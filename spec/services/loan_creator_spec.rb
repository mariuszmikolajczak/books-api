# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoanCreator, type: :service do
  subject(:call) { described_class.call(book_serial_number:, reader_card_number:) }

  let(:book) { create(:book, serial_number: "000001") }
  let(:reader) { create(:reader, card_number: "000001") }
  let(:book_serial_number) { book.serial_number }
  let(:reader_card_number) { reader.card_number }

  it "creates a new loan" do
    freeze_time
    expect(call).to match_array([:ok, an_instance_of(Loan)])
    expect(book.reload.status).to eq("borrowed")
    expect(book.loans.count).to eq(1)
    loan = book.loans.last
    expect(loan.borrowed_at).to eql(Time.current)
    expect(loan.due_at).to eq(30.days.from_now)
    unfreeze_time
  end

  context "when book is not found" do
    let(:book_serial_number) { "nonexistent" }

    it "returns error" do
      expect(call).to match_array([:error, :book_not_found])
    end
  end

  context "when reader is not found" do
    let(:reader_card_number) { "nonexistent" }

    it "returns error" do
      expect(call).to match_array([:error, :reader_not_found])
    end
  end

  context "when book already borrowed" do
    let(:book) { create(:book, serial_number: "000002", status: "borrowed") }

    it "returns error" do
      expect(call).to match_array([:error, :book_already_borrowed])
    end
  end

  context "when an exception occurs" do
    before do
      allow(Book).to receive(:find_by).and_raise(StandardError, "Unexpected error")
    end

    it "returns error" do
      expect(call).to match_array([:exception, "Unexpected error"])
    end
  end
end
