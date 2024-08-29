class Item < ApplicationRecord
  belongs_to :user
  has_many :bids, dependent: :destroy
  has_one :transaction, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :starting_price, presence: true, numericality: { greater_than: 0 }
  validates :auction_duration, presence: true
  validates :auction_end_time, presence: true
end
