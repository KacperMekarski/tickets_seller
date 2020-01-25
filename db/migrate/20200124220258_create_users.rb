class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, unique: true
      t.string :full_name, null: false
      t.timestamps
    end
  end
end
