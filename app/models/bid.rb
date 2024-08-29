class Bid < ApplicationRecord
  belongs_to :item
  belongs_to :user

  validates :bid_amount, presence: true, numericality: { greater_than: 0 }
  validate :bid_amount_greater_than_starting_price

  private

  def bid_amount_greater_than_starting_price
    if bid_amount.present? && item.present? && bid_amount <= item.starting_price
      errors.add(:bid_amount, "must be greater than the starting price")
    end
  end
end
