Spree::ShipmentHandler.class_eval do
  def perform(emailed = false)
    @shipment.inventory_units.each &:ship!
    @shipment.process_order_payments if Spree::Config[:auto_capture_on_dispatch]
    send_shipped_email unless emailed
    @shipment.touch :shipped_at
    update_order_shipment_state
  end
end
