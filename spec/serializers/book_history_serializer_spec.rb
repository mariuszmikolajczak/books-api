# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookHistorySerializer, type: :serializer do
  subject(:book_history_serializer) { described_class.new(book) }

  let(:book) { create(:book) }

  before do
    create_list(:loan, 10, book:, returned_at: Time.current)
  end

  it "serializes a book correctly" do
    expect(book_history_serializer.as_json).to eql({
      id: book.id,
      serial_number: book.formatted_serial,
      title: book.title,
      author: book.author,
      status: book.status,
      loans: book.loans.map { SimpleLoanSerializer.one(it) }
    })
  end

  context "when using static method" do
    subject { described_class }

    let(:resource) { create(:book) }
    let(:resources) { create_list(:book, 3) }

    include_examples "common methods"
  end
end
