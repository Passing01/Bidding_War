module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :set_transaction, only: [:show, :update, :destroy]

      # GET /api/v1/transactions
      def index
        @transactions = Transaction.all
        render json: @transactions
      end

      # GET /api/v1/transactions/:id
      def show
        render json: @transaction
      end

      # POST /api/v1/transactions
      def create
        @transaction = Transaction.new(transaction_params)
        if @transaction.save
          render json: @transaction, status: :created
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/transactions/:id
      def update
        if @transaction.update(transaction_params)
          render json: @transaction
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/transactions/:id
      def destroy
        @transaction.destroy
        head :no_content
      end

      private

      def set_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(:item_id, :buyer_id, :seller_id, :final_price, :payment_status, :delivery_status)
      end
    end
  end
end
