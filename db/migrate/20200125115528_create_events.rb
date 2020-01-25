# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.datetime :happens_at, null: false
      t.integer :ticket_price, null: false
      t.integer :tickets_available, null: false
      t.timestamps
    end
  end
end
