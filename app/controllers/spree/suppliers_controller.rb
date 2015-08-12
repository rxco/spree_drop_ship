class Spree::SuppliersController < Spree::StoreController
  before_filter :check_authorization, only: [:edit, :update, :new, :verify, :destroy]
  before_filter :is_new_supplier, only: [:new]
  before_filter :supplier, only: [:edit, :update, :show, :verify, :destroy]
  before_filter :is_supplier, only: [:edit, :update, :verify, :destroy]

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
      flash[:success] = "Your shop has been Created! Add a product"
      render "verify"
    else
      render "new"
    end
  end

  def show
    @products = Spree::Product.find_by supplier_id: @supplier.id
    @title = "Shop #{@supplier.name}"
  end

  def update
    if @supplier.update_attributes supplier_params
      flash[:success] = "Your shop has been updated!"
      redirect_to @supplier
    else
      logger.debug @supplier.errors.messages.inspect
      render "edit"
    end
  end

  def destroy
    if @supplier.destroy
      flash[:success] = "Your shop has been deleted!"
      render "index"
    end
  end

  private

  def check_authorization
    action = params[:action].to_sym
    resource = Spree::Supplier

    authorize! action, resource, session[:access_token]
  end

  def is_new_supplier
    unless !spree_current_user.supplier?
      flash[:error] = "You already have a shop setup!"
      redirect_to spree_current_user.supplier
    end
  end

  def supplier
    @supplier = Spree::Supplier.friendly.find(params[:id])
  end

  def is_supplier
    unless try_spree_current_user && (spree_current_user.supplier_id === @supplier.id)
      flash[:error] = "You don't hav permission to access this content!"
      redirect_to @supplier
    end
  end

  def supplier_params
    params.require(:supplier).permit(:name, :slug, :description, :banner, :email)
  end
end