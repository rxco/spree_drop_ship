Spree::ProductsController.class_eval do
  before_filter :check_authorization, only: [:edit, :update, :new]
  before_filter :get_product, only: [:edit]
  before_filter :is_owner, only: [:edit]

  def new
    @product = Spree::Product.new
  end

  def create
    uuid = Digest::MD5.hexdigest(Time.now.to_s).gsub(/[^0-9]/i, '').truncate(10)
    params[:product][:supplier_id] = spree_current_user.supplier_id
    params[:product][:sku] = 'S' + spree_current_user.supplier_id.to_s + '-P' + uuid
    params[:product][:shipping_category_id] = 1
    params[:product][:available_on] = Time.now.to_formatted_s(:db)

    @product = Spree::Product.new product_params

    if params[:image].any?
      params[:image][:alt] = 'Some Alt text'
      params[:image][:position] = 3
      params[:image][:viewable_type] = 'Spree::Variant'
      params[:image][:viewable_id] = 39
      @image = Spree::Image.new image_params;

      abort @image.save
    end


    if @product.save
      redirect_to @product
    else
      render 'new'
    end
  end

  def update
    if @product.update_attributes supplier_params
      redirect_to @product
    else
      render 'edit'
    end
  end

  private

  def check_authorization
    action = params[:action].to_sym
    resource = Spree::Product

    authorize! action, resource, session[:access_token]
  end

  def is_owner
    unless spree_current_user.supplier_id === @product.supplier_id
      flash[:error] = "You don't hav permission to access this content!"
      redirect_to @product
    end
  end

  def get_product
    @product = Spree::Product.friendly.find(params[:id])
  end

  def product_params
    permit = permitted_product_attributes + [:supplier_id]
    params.require(:product).permit(permit)
  end

  def image_params
    params.require(:image).permit(Spree::PermittedAttributes.image_attributes)
  end
end