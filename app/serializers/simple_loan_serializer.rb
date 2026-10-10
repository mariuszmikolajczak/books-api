# frozen_string_literal: true

class SimpleLoanSerializer
  extend CommonMethods

  def initialize(loan) = @loan = loan

  def as_json
    {
      id: @loan.id,
      borrowed_at: @loan.borrowed_at,
      due_at: @loan.due_at,
      returned_at: @loan.returned_at
    }
  end
end
