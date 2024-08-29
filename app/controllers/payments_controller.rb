class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def create
    token = params[:stripeToken]
    amount = params[:amount].to_i * 100 # Convertir en cents

    begin
      customer = Stripe::Customer.create(
        email: current_user.email,
        source: token
      )

      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: amount,
        description: 'Achat d\'objet',
        currency: 'usd'
      )

      if charge.paid
        @transaction = Transaction.create(
          item_id: params[:item_id],
          buyer_id: current_user.id,
          seller_id: Item.find(params[:item_id]).user_id,
          final_price: amount / 100.0,
          payment_status: 'completed',
          delivery_status: 'pending'
        )
        render json: { message: 'Paiement réussi', transaction: @transaction }, status: :ok
      else
        render json: { message: 'Paiement échoué' }, status: :unprocessable_entity
      end
    rescue Stripe::CardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end
end
