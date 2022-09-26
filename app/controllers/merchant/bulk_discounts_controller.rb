class Merchant::BulkDiscountsController < Merchant::BaseController
  #merchant is being set in the base controller

  def index
    @discounts = @merchant.bulk_discounts
  end

  def show
    @discount = BulkDiscount.find(params[:id])
  end

  def new
  end

  def create
    @bulk_discount = @merchant.bulk_discounts.create!(discount_params)
    redirect_to(merchant_bulk_discounts_path(@merchant))
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
    @discount.update!(discount_params)
    redirect_to merchant_bulk_discount_path(@merchant, @discount)
  end

  private
  
  def discount_params
    params.permit(:quantity_threshold, :merchant_id, :percentage_discount)
  end



end