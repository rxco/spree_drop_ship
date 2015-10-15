module Spree
  module Api
    class SuppliersController < Spree::Api::BaseController

      def index
          @suppliers = Spree::Supplier.accessible_by(current_ability, :read).ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
          respond_with(@suppliers)
      end

      def show
        @supplier = Spree::Supplier.find(params[:id])
        respond_with(@supplier)
      end

    end
  end
end