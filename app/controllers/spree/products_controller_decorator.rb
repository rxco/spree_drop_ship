Spree::ProductsController.class_eval do
  before_filter :is_supplier, only: [:new, :create, :edit]
  before_filter :get_product, only: [:edit]
  before_filter :is_owner, only: [:edit]

  def new
    @product = Spree::Product.new
  end

  def create
    params[:product][:supplier_id] = spree_current_user.supplier_id
    params[:product][:shipping_category_id] = 1
    @product = Spree::Product.new product_params
    if @product.save
      redirect_to action: "show", id: @product.slug
    else
      render 'new'
    end
  end

  def edit
    # TODO
  end

  private

  def is_supplier
    unless try_spree_current_user && spree_current_user.supplier_id?
      flash[:error] = "You don't hav permission to access this content!"
      redirect_to action: "index"
    end
  end

  def is_owner
    unless try_spree_current_user && (spree_current_user.admin? || spree_current_user.supplier_id == @product.supplier_id)
      flash[:error] = "You don't hav permission to access this content!"
      redirect_to action: "show", id: @product.slug
    end
  end

  def get_product
    @product = Spree::Product.friendly.find(params[:id])
  end

  def product_params
    permit = permitted_product_attributes + [:supplier_id]
    params.require(:product).permit(permit)
  end
end