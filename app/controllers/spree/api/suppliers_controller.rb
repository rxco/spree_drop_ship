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

      def update
        @supplier = Spree::Supplier.friendly.find(params[:id])
        authorize! :update, @suppplier

        if @supplier.update_attributes supplier_params
          respond_with(@supplier.reload, :status => 200, :default_template => :show)
        else
          invalid_resource!(@supplier)
        end
      end

      private

      def supplier_params
        params.require(:supplier).permit(:name, :slug, :description, :banner, :email, :address_attributes, :return_policy, :featured)
      end

    end
  end
end