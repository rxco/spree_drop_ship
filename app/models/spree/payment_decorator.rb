module Spree
  Payment.class_eval do

    belongs_to :payable, polymorphic: true

    def supplier
      Spree::Supplier.by_stripe_account(self.destination)
    end
  end
end
