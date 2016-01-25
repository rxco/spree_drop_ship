module Spree
  module Api
    class EarningsController < Spree::Api::BaseController
      def show
        supplier = Spree::Supplier.find_by(:email => params[:email].downcase)
        earnings = {}
        if supplier.present?
          @earnings = Spree::Earning.new(supplier)
          earnings = @earnings.fetch
        end
        render :json => earnings
      end
    end
  end
end