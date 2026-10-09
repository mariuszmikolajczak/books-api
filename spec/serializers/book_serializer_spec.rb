# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BookSerializer, type: :serializer do
  subject(:book_serializer) { described_class.new(book) }

  let(:book) { create(:book) }

  it "serializes a book correctly" do
    expect(book_serializer.as_json).to eql({
      id: book.id,
      serial_number: book.formatted_serial,
      title: book.title,
      author: book.author,
      status: book.status
    })
  end
end
