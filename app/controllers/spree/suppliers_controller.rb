class Spree::SuppliersController < Spree::StoreController

  before_filter :is_new_supplier, only: [:new]
  before_filter :get_supplier, only: [:edit, :update, :show]
  before_filter :is_supplier, only: [:edit]

  def index
    @suppliers = Spree::Supplier.all
  end

  def new
      @supplier = Spree::Supplier.new
  end

  def create
    params[:supplier][:email] = spree_current_user.email
    @supplier = Spree::Supplier.new supplier_params
    if @supplier.save
      flash[:success] = "Your store has been Created! Add a product"
      redirect_to new_product_path
    else
      render 'new'
    end
  end

  def show
    @products = Spree::Product.find_by supplier_id: @supplier.id
    @title = "Shop #{@supplier.name}"
  end

  def update
    if @supplier.update_attributes supplier_params
      flash[:success] = "Your store has been updated!"
      redirect_to @supplier
    else
      logger.debug @supplier.errors.messages.inspect
      render "edit"
    end
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
      redirect_to @supplier
    end
  end

  def supplier_params
    params.require(:supplier).permit(:name, :slug, :description, :banner, :email)
  end
end