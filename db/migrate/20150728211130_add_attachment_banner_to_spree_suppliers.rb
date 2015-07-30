class AddAttachmentBannerToSpreeSuppliers < ActiveRecord::Migration
  def self.up
    change_table :spree_suppliers do |t|
      t.attachment :banner
    end
  end
end