# frozen_string_literal: true

class LoanReturner
  def self.call(...) = new(...).call

  def initialize(book_serial_number:)
    @book_serial_number = book_serial_number
    @book = nil
    @loan = nil
  end

  def call
    return [:error, :book_not_found] unless book.present?
    return [:error, :no_active_loan] unless book.status.casecmp?("borrowed")

    book.with_lock do
      book.update!(status: :available)
      loan.update!(returned_at: Time.zone.now)

      [:ok, nil]
    end
  rescue => e
    [:exception, e.message]
  end

  private

  attr_reader :book_serial_number

  def book = @book ||= Book.find_by(serial_number: book_serial_number)

  def loan = @loan ||= book.loans.active.first
end
