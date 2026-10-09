# frozen_string_literal: true

class BookSerializer
  def self.many(books) = books.map { new(it).as_json }

  def initialize(book) = @book = book

  def as_json
    {
      id: @book.id,
      serial_number: @book.formatted_serial,
      title: @book.title,
      author: @book.author,
      status: @book.status
    }
  end
end
