# frozen_string_literal: true

class LoanCreator
  def self.call(...) = new(...).call

  def initialize(book_serial_number:, reader_card_number:)
    @book_serial_number = book_serial_number
    @reader_card_number = reader_card_number
    @book = nil
    @reader = nil
  end

  def call
    return [:error, :book_not_found] unless book.present?
    return [:error, :reader_not_found] unless reader.present?

    book.with_lock do
      next [:error, :book_already_borrowed] unless book.available?

      book.update!(status: :borrowed)

      [:ok, book.loans.create!(reader:, borrowed_at:, due_at:)]
    end
  rescue => e
    [:exception, e.message]
  end

  private

  attr_reader :book_serial_number, :reader_card_number

  def book = @book ||= Book.find_by(serial_number: book_serial_number)

  def reader = @reader ||= Reader.find_by(card_number: reader_card_number)

  def borrowed_at = Time.zone.now

  def due_at = borrowed_at + Rails.application.config.x.book_borrow_time.days
end
