object @supplier

attributes *Spree::Supplier.column_names
node(:banner_url_small) { |s| s.banner.url(:small).to_s }
node(:banner_url_large) { |s| s.banner.url(:large).to_s }
node(:products_count) { |s| s.products.count}
node(:products) { |s|
    child s.products => :products do
      extends "spree/api/products/show"
    end
}
node(:fans) { |s| s.favorites.count }
node(:verified) { |s| s.verified? }