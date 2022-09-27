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
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = @merchant.bulk_discounts.new(discount_params)
    if @bulk_discount.save
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
      require 'pry' ; binding.pry
      redirect_to edit_merchant_bulk_discount_path(@merchant, @discount)
      #flash messages will appear due to validation testing
    end
  end

  private
  
  def discount_params
    params.permit(:quantity_threshold, :merchant_id, :percentage_discount)
  end



end