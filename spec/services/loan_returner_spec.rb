# frozen_string_literal: true

require "rails_helper"

RSpec.describe LoanReturner, type: :service do
  subject(:call) { described_class.call(book_serial_number:) }

  let(:book) { create(:book, serial_number: "000001", status: "borrowed") }
  let!(:loan) { create(:loan, book:, returned_at: nil) }
  let(:book_serial_number) { book.serial_number }

  it "returns book" do
    freeze_time
    expect(call).to match_array([:ok, nil])
    expect(book.reload.status).to eq("available")
    expect(loan.reload.returned_at).to eql(Time.current)
    unfreeze_time
  end

  context "when book is not found" do
    let(:book_serial_number) { "nonexistent" }

    it "returns error" do
      expect(call).to match_array([:error, :book_not_found])
    end
  end

  context "when book available" do
    let(:book) { create(:book, serial_number: "000002", status: "available") }

    it "returns error" do
      expect(call).to match_array([:error, :no_active_loan])
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
