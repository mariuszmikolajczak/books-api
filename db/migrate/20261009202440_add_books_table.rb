# frozen_string_literal: true

class AddBooksTable < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.integer :serial_number, null: false
      t.string :title, null: false
      t.string :author, null: false
      t.string :status, null: false, default: "available"

      t.timestamps
    end

    add_index :books, :serial_number, unique: true
  end
end
