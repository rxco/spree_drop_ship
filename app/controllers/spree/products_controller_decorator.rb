Spree::ProductsController.class_eval do
  before_filter :check_authorization, only: [:edit, :update, :new, :destroy]
  before_filter :product, only: [:edit, :update, :destroy]
  before_filter :is_owner, only: [:edit, :destroy]
  before_filter :load_data, only: [:new, :edit, :create]
  before_filter :load_supplier, only: [:show, :destroy]

  def new
    @product = Spree::Product.new
    @title = "New Product"
    @body_id = 'product-manage'
    @selected = 'product' if params[:onboard].present?
  end

  def create
    @title = "New Product"
    @body_id = 'product-manage'

    uuid = Digest::SHA1.hexdigest([Time.now, rand].join)[0, 10].gsub(/\D/, '')
    params[:product][:sku] = 'S' + spree_current_user.supplier_id.to_s + '-P' + uuid
    params[:product][:supplier_id] = spree_current_user.supplier_id
    params[:product][:available_on] = Time.now.to_formatted_s(:db)

    @product = Spree::Product.new product_params

    if @product.save
      variant = Spree::Variant.find_by_sku(params[:product][:sku])
      logger.debug variant.inspect

      # Add Initial Stock
      location = Spree::StockLocation.find_by_supplier_id(@product.supplier_id)
      logger.debug "LOCATION: #{location}"
      stock = Spree::StockItem.where(:stock_location_id => location.id, :variant_id => variant.id).first_or_create
      logger.debug stock.inspect
      stock.set_count_on_hand(params[:product][:total_on_hand].to_i)
      logger.debug stock.inspect

      # Taxonomy
      if params[:product][:taxon_ids].present?
        taxon_ids = params[:product][:taxon_ids] = params[:product][:taxon_ids].split(',')
        taxon_ids.each do |id|
          taxon = Spree::Taxon.find_by_id(id)
          if !taxon.nil? and !@product.taxons.include?(taxon)
            @product.taxons << taxon
          end
        end
      end

      # Images
      if params[:images].present?
        params[:images].each do |key, image|
          params[:image] = {}
          # params[:image][:attachment] = image
          # params[:image][:alt] = 'Some Alt text'
          params[:image][:position] = key.to_i + 1
          params[:image][:viewable_type] = 'Spree::Variant'
          params[:image][:viewable_id] = variant.id
          params[:image][:crop] = params[:crop]['image' + key]
          attachment = Spree::Image.new image_params
          attachment.attachment_remote_url=(params[:key]['image' + key])
          if attachment.save
            attachment.attachment_delete(params[:key]['image' + key])
          end
        end
      end

      # Option Types
      if params[:product][:option_type_ids].present?
        option_types = []
        params[:product][:option_type_ids].split(',').each do |id|
          option = Spree::OptionType.find_by_id(id)
          if option.present?
            option_types << option
          end
        end
        @product.option_types = option_types
      end

      # Variants
      # if params[:variants].present?
      #   @product.build_variants_from_option_values_hash(params[:variants], params[:product][:sku])
      # end

      redirect_to @product
    else
      render 'new'
    end

  end

  def edit
    @body_id = 'product-manage'
  end

  def update
    if @product.update_attributes product_params
      redirect_to @product
    else
      render 'edit'
    end
  end

  def destroy
    if @product.destroy
      flash[:success] = "Your product has been deleted!"
      redirect_to @supplier
    end
  end

  def image
    errors = validate_file(params)
    if errors.blank?
      content_type = params['type']
      extension = Rack::Mime::MIME_TYPES.invert[content_type]
      file_string = "uploads/#{SecureRandom.uuid}#{extension}"
      presigned_post = S3_BUCKET.presigned_post(
          key: file_string,
          success_action_status: 201,
          acl: :public_read,
          content_type: content_type,
          expires_header: 1.hour.from_now.httpdate
      )
      render :json => {
        result: true,
        url: presigned_post.url,
        data: presigned_post.fields
      }
    else
      render :json => {
        result: false,
        errors: errors
      }
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

  def product
    @product = Spree::Product.friendly.find(params[:id])
  end

  def product_params
    permit = permitted_product_attributes + [:supplier_id]
    params.require(:product).permit(permit)
  end

  def image_params
    permit = Spree::PermittedAttributes.image_attributes + [:crop]
    params.require(:image).permit(permit)
  end

  def variant_params
    params.require(:variant).permit(Spree::PermittedAttributes.variant_attributes)
  end

  def load_data
    @option_types = Spree::OptionType.order(:name)
    values = Spree::OptionValue.all
    @option_values =  values.to_json(:only => [:id, :name, :presentation, :option_type_id])
    @taxonomy = Spree::Taxon.order(:name).where(:depth => 0)
    @sub1 = Spree::Taxon.order(:name).where(:depth => 1)
    @sub2 = Spree::Taxon.order(:name).where(:depth => 2)

    # @tax_categories = TaxCategory.order(:name)
    @shipping_categories = Spree::ShippingCategory.order(:id)
  end

  def load_supplier
    @supplier = Spree::Supplier.find_by(:id => @product.supplier_id)
    @products = @supplier.products(@product.id)
  end

  def validate_file(params)
    errors = []
    if params['size'].to_i > 5000001
      errors << "5MB max file size allowed."
    end
    if !params['type'].match(/\Aimage\/.*\Z/)
      errors << "Only JPG, PNG and GIF files are allowed."
    end

    errors
  end
end