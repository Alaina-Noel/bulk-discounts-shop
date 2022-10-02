class Merchant::BulkDiscountsController < Merchant::BaseController
  #merchant is being set in the base controller, that is why it doesn't appear in each method.

  def index
    @discounts = @merchant.bulk_discounts
  end

  def show
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @discount = BulkDiscount.new
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @discount = @merchant.bulk_discounts.new(discount_params)
    if @discount.save
      redirect_to(merchant_bulk_discounts_path(@merchant))
    else
      redirect_to(new_merchant_bulk_discount_path(@merchant))
      #flash messages will appear due to validation testing
    end
  end

  def destroy
    BulkDiscount.find(params[:id]).destroy
    redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts"
  end
  
  def edit
    @discount = @merchant.bulk_discounts.find(params[:id])
  end

  def update
    @discount = @merchant.bulk_discounts.find(params[:id])
    if @discount.update(discount_params)
      redirect_to merchant_bulk_discount_path(@merchant, @discount)
    else
      redirect_to edit_merchant_bulk_discount_path(@merchant, @discount)
      flash[:notice] = "You must fill in a quantity"
    end
  end

  private
  
  def discount_params
    params.require(:bulk_discount).permit(:quantity_threshold, :merchant_id, :percentage_discount)
  end

end