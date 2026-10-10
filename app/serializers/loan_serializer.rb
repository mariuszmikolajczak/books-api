# frozen_string_literal: true

class LoanSerializer
  extend CommonMethods

  def initialize(loan) = @loan = loan

  def as_json
    {
      id: @loan.id,
      book: BookSerializer.one(@loan.book),
      reader: ReaderSerializer.one(@loan.reader),
      borrowed_at: @loan.borrowed_at,
      due_at: @loan.due_at,
      returned_at: @loan.returned_at
    }
  end
end
