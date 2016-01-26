class Spree::Earning

  def initialize(supplier)
    stock_location = supplier.stock_locations
    @shipments = Spree::Shipment.where("spree_shipments.stock_location_id = ? AND spree_shipments.state != ? AND spree_shipments.state != ?", stock_location.first.id, "pending", "canceled")
  end

  def fetch
    earnings = {
        'today' => today,
        'yesterday' => yesterday,
        'rolling_31' => rolling,
        'all_time' => all_time
    }
    earnings
  end

  private

  def today
    shipments = @shipments.where("created_at >= ? AND created_at <= ?", Date.today.to_time.beginning_of_day, Date.today.to_time.end_of_day)
    earnings = 0
    shipments.each do |s|
      earnings += s.supplier_commission.to_f
    end
    Spree::Money.new earnings
  end

  def yesterday
    shipments = @shipments.where("created_at >= ? AND created_at <= ?", Date.yesterday.to_time.beginning_of_day, Date.yesterday.to_time.end_of_day)
    earnings = 0
    shipments.each do |s|
      earnings += s.supplier_commission.to_f
    end
    Spree::Money.new earnings
  end

  def rolling
    shipments = @shipments.where("created_at < ? AND created_at > ?",Date.yesterday.to_time.end_of_day, 31.day.ago.to_time.beginning_of_day)
    earnings = 0
    shipments.each do |s|
      earnings += s.supplier_commission.to_f
    end
    Spree::Money.new earnings
  end

  def all_time
    earnings = 0
    @shipments.each do |s|
      earnings += s.supplier_commission.to_f
    end
    Spree::Money.new earnings
  end

end