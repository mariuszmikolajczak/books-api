# frozen_string_literal: true

class LoanSerializer < SimpleLoanSerializer
  extend CommonMethods

  def as_json
    super.merge(
      book: BookSerializer.one(@loan.book)
    )
  end
end
