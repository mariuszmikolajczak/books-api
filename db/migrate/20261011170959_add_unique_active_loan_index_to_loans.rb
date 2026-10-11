# frozen_string_literal: true

class AddUniqueActiveLoanIndexToLoans < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :loans, :book_id,
      unique: true,
      where: "returned_at IS NULL",
      name: "index_loans_on_active_book_id",
      algorithm: :concurrently
  end
end
