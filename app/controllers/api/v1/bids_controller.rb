module Api
  module V1
    class BidsController < ApplicationController
      before_action :set_bid, only: [:show, :update, :destroy]

      # GET /api/v1/bids
      def index
        @bids = Bid.all
        render json: @bids
      end

      # GET /api/v1/bids/:id
      def show
        render json: @bid
      end

      # POST /api/v1/bids
      def create
        @bid = Bid.new(bid_params)
        if @bid.save
          render json: @bid, status: :created
        else
          render json: @bid.errors, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/bids/:id
      def update
        if @bid.update(bid_params)
          render json: @bid
        else
          render json: @bid.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/bids/:id
      def destroy
        @bid.destroy
        head :no_content
      end

      private

      def set_bid
        @bid = Bid.find(params[:id])
      end

      def bid_params
        params.require(:bid).permit(:item_id, :user_id, :bid_amount)
      end
    end
  end
end
