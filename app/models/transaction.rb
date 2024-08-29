class Transaction < ApplicationRecord
  belongs_to :item
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'

  validates :final_price, presence: true, numericality: { greater_than: 0 }
  validates :payment_status, presence: true
  validates :delivery_status, presence: true
end
