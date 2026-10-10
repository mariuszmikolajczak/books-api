# frozen_string_literal: true

class BookHistorySerializer < BookSerializer
  extend CommonMethods

  def as_json = super.merge(loans: SimpleLoanSerializer.many(@book.loans))
end
