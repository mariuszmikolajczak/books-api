# frozen_string_literal: true

class BookArchiver
  def self.call(...) = new(...).call

  def initialize(book) = @book = book

  def call
    return [:error, "Cannot archive a borrowed book"] unless @book.status == "available"

    unless @book.update(status: "archived")
      return [:error, @book.errors.full_messages.join(", ")]
    end

    [:ok, nil]
  end
end
