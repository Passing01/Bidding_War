class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :starting_price, null: false
      t.interval :auction_duration, null: false
      t.timestamp :auction_end_time, null: false
      t.timestamps
    end
  end
end
