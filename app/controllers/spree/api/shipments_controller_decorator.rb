Spree::Api::ShipmentsController.class_eval do
  def ship
    unless @shipment.shipped?
      @shipment.confirmation_delivered= params[:message] == '0'
      @shipment.ship!
    end
    respond_with(@shipment, default_template: :show)
  end
end
