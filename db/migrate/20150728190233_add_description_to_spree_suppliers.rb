class AddDescriptionToSpreeSuppliers < ActiveRecord::Migration
  def change
    add_column :spree_suppliers, :description, :varchar, after: :name
  end
end
