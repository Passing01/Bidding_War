class NotificationMailer < ApplicationMailer
  default from: 'notifications@yourdomain.com'

  def new_bid_email(user, item, bid)
    @user = user
    @item = item
    @bid = bid
    mail(to: @user.email, subject: 'New Bid on Your Item')
  end

  def auction_ended_email(user, item)
    @user = user
    @item = item
    mail(to: @user.email, subject: 'Auction Ended')
  end

  def sale_finalized_email(user, transaction)
    @user = user
    @transaction = transaction
    mail(to: @user.email, subject: 'Sale Finalized')
  end
end
