class Spree::SuppliersController < Spree::StoreController

  before_filter :is_new_supplier, only: [:new]
  before_filter :get_supplier, only: [:edit, :show]
  before_filter :is_supplier, only: [:edit]

  def index
    # TODO List of suppliers
  end

  def new
      @supplier = Spree::Supplier.new(address_attributes: {country_id: Spree::Address.default.country_id})
  end

  def show
    @products = Spree::Product.find_by supplier_id: @supplier.id
  end

  def edit
    # TODO
  end

  private

  def is_new_supplier
    unless try_spree_current_user && !spree_current_user.supplier_id?
      flash[:error] = "You don't hav permission to access this content!"
      redirect_to action: "index"
    end
  end

  def get_supplier
    @supplier = Spree::Supplier.friendly.find(params[:id])
  end

  def is_supplier
    unless try_spree_current_user && (spree_current_user.admin? || spree_current_user.supplier_id == @supplier.id)
      flash[:error] = "You don't hav permission to access this content!"
      redirect_to action: "show", id: @supplier.slug
    end
  end
end