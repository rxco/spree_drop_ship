Spree::Product.class_eval do

  has_many :suppliers, through: :master

  def add_supplier!(supplier_or_id)
    supplier = supplier_or_id.is_a?(Spree::Supplier) ? supplier_or_id : Spree::Supplier.find(supplier_or_id)
    populate_for_supplier! supplier if supplier
  end

  def add_suppliers!(supplier_ids)
    Spree::Supplier.where(id: supplier_ids).each do |supplier|
      populate_for_supplier! supplier
    end
  end

  # Returns true if the product has a drop shipping supplier.
  def supplier?
    suppliers.present?
  end

  def is_supplier?(user = nil)
    user && user.supplier_id == self.supplier_id
  end

  def supplier_name
    Spree::Supplier.friendly.find(self.supplier_id).name
  end

  # TODO Look for other way to add variants to product
  # Builds variants from a hash of option types & values
  def build_variants_from_option_values_hash(option_values_hash, sku)
    ensure_option_types_exist_for_values_hash
    values = option_values_hash.values

    # values = values.inject(values.shift) { |memo, value| memo.product(value).map(&:flatten) }
    values.each_with_index  do |value, index|
      variant = variants.create(
          option_value_ids: value[:ids],
          price: value[:price],
          position: index + 1,
          stock_items_count: value[:quantity],
          sku: sku + '-' + index.to_s
      )
    end
    save
  end

  private

  def populate_for_supplier!(supplier)
    variants_including_master.each do |variant|
      unless variant.suppliers.pluck(:id).include?(supplier.id)
        variant.suppliers << supplier
        supplier.stock_locations.each { |location| location.propagate_variant(variant) }
      end
    end
  end

end
