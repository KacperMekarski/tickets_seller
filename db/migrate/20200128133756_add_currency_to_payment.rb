class AddCurrencyToPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :currency, :string, null: false, default: "EUR"
  end
end
