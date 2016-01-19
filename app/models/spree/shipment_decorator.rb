Spree::Shipment.class_eval do
  # TODO here to fix cancan issue thinking its just Order
  belongs_to :order, class_name: 'Spree::Order', touch: true, inverse_of: :shipments

  has_many :payments, as: :payable

  scope :by_supplier, -> (supplier_id) { joins(:stock_location).where(spree_stock_locations: { supplier_id: supplier_id }) }

  delegate :supplier, to: :stock_location

  def display_final_price_with_items
    Spree::Money.new final_price_with_items
  end

  def item_cost
    self.manifest.map { |m| m.line_item.price * m.quantity }.sum
  end

  def final_price_with_items
    self.item_cost + self.final_price
  end

  def supplier_commission_total
    if self.supplier.present? && self.supplier.commission_percentage.present?
      self.final_price_with_items * self.supplier.commission_percentage
    else
      self.final_price_with_items * SpreeDropShip::Config[:default_commission_percentage].to_f
    end
  end

  def update_commission
    update_column :supplier_commission, self.supplier_commission_total
  end

  # private
  #
  # durably_decorate :after_ship, mode: 'soft', sha: 'e8eca7f8a50ad871f5753faae938d4d01c01593d' do
  #   original_after_ship
  #
  #   if supplier.present?
  #     update_commission
  #   end
  # end


end
