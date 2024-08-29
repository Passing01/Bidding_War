module Api
  module V1
    class ItemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_item, only: [:show, :update, :destroy]
      before_action :authorize_item, only: [:show, :update, :destroy]

      def index
        @items = policy_scope(Item)
        render json: @items
      end

      def show
        render json: @item
      end

      def create
        @item = Item.new(item_params)
        authorize @item
        if @item.save
          render json: @item, status: :created
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      def update
        if @item.update(item_params)
          render json: @item
        else
          render json: @item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @item.destroy
        head :no_content
      end

      private

      def set_item
        @item = Item.find(params[:id])
      end

      def authorize_item
        authorize @item
      end

      def item_params
        params.require(:item).permit(:user_id, :title, :description, :starting_price, :auction_duration, :auction_end_time)
      end
    end

  end
end
