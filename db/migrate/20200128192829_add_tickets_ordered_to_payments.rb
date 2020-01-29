# frozen_string_literal: true

class AddTicketsOrderedToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :tickets_ordered_amount, :integer, null: false
  end
end
