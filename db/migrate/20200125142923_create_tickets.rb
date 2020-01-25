class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.references :payment, foreign_key: true
      t.references :event, foreign_key: true
      t.timestamps
    end
  end
end
