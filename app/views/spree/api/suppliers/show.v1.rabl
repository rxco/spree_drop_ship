object @supplier

attributes *Spree::Supplier.column_names
node(:banner_url_small) { |s| s.banner.url(:small).to_s }
node(:banner_url_large) { |s| s.banner.url(:large).to_s }
node(:products_count) { |s| s.products.count}
node(:products) { |s|
    s.products do
      extends "spree/api/products/show"
    end
}