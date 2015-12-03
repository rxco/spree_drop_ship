object @line_item
cache [I18n.locale, root_object]
attributes *line_item_attributes
child :product do
  child :product_properties => :properties do
    attributes *product_property_attributes
  end
end
node(:note) { |li| li.note}
node(:single_display_amount) { |li| li.single_display_amount.to_s }
node(:display_amount) { |li| li.display_amount.to_s }
node(:total) { |li| li.total }
node(:supplier) { |li|
  child li.product.supplier => :supplier do |supplier|
     node(:name) {|s| s.name }
     node(:uri) {|s| s.slug }
  end
}
child :variant do
  extends "spree/api/variants/small"
  attributes :product_id
  child(:images => :images) { extends "spree/api/images/show" }
end

child :adjustments => :adjustments do
  extends "spree/api/adjustments/show"
end