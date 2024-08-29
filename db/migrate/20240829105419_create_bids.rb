class CreateBids < ActiveRecord::Migration[6.0]
  def change
    create_table :bids do |t|
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :bid_amount, null: false
      t.timestamps
    end
  end
end
