# frozen_string_literal: true

class Api::V1::LoansController < Api::V1::BaseController
  def create
    case LoanCreator.call(book_serial_number:, reader_card_number:)
    in [:ok, loan]
      render json: LoanSerializer.one(loan), status: :created
    in [:error, message]
      render_error(I18n.t("loans.#{message}"))
    in [:exception, message]
      render_error(message, :internal_server_error)
    else
      render_error
    end
  end

  def return_book
    case LoanReturner.call(book_serial_number:)
    in [:ok, nil]
      head :no_content
    in [:error, message]
      render_error(I18n.t("loans.#{message}"))
    in [:exception, message]
      render_error(message, :internal_server_error)
    else
      render_error
    end
  end

  private

  def book_serial_number = params.expect(:book_serial_number)

  def reader_card_number = params.expect(:reader_card_number)
end
