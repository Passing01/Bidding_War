class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.references :item, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.decimal :final_price, null: false
      t.string :payment_status, null: false
      t.string :delivery_status, null: false
      t.timestamps
    end
  end
end
