class BidsController < ApplicationController
  def create
    @bid = Bid.new(bid_params)
    if @bid.save
      ActionCable.server.broadcast "notifications_#{@bid.item.user.id}", message: "New bid on #{@bid.item.title}"
      NotificationMailer.new_bid_email(@bid.item.user, @bid.item, @bid).deliver_later
      render json: @bid, status: :created
    else
      render json: @bid.errors, status: :unprocessable_entity
    end
  end

  private

  def bid_params
    params.require(:bid).permit(:item_id, :user_id, :bid_amount)
  end
end
