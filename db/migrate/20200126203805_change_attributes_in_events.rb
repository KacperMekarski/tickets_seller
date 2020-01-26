class ChangeAttributesInEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :tickets_amount, :integer, null: false
  end
end
