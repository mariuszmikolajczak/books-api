# frozen_string_literal: true

class AddReadersTable < ActiveRecord::Migration[8.1]
  def change
    create_table :readers do |t|
      t.integer :card_number, null: false
      t.string :full_name, null: false
      t.string :email, null: false
      t.timestamps
    end

    add_index :readers, :email, unique: true
    add_index :readers, :card_number, unique: true
  end
end
