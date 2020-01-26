# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.integer :paid_amount, null: false
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true
      t.timestamps
    end
  end
end
