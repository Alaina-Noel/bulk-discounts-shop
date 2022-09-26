class Invoice < ApplicationRecord
  enum status: [:cancelled, :completed, :in_progress]
  
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  def self.incomplete_invoices
    where("status = 2").order(:created_at)
  end

  def merchant_items(merchant)
    self.items.where(items: { merchant_id: merchant.id } ).distinct
  end

  def calculate_invoice_revenue
    self.invoice_items.sum("quantity*unit_price")
  end

  def calculate_revenue_for(merchant)
    merchant.invoice_items.sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def calculate_discounted_invoice_revenue(merchant)
    discount = merchant.invoice_items.joins(:bulk_discounts).select("invoice_items.id, (invoice_items.quantity * invoice_items.unit_price) * max(bulk_discounts.percentage_discount * .01) as remaining_revenue").where("invoice_items.quantity >= bulk_discounts.quantity_threshold").group("invoice_items.id").sum(&:remaining_revenue).to_i 
    calculate_revenue_for(merchant) - discount
  end

  def discount_applied?(item)
    ids = item.invoice_items.joins(:bulk_discounts).select("invoice_items.id").where("invoice_items.quantity >= bulk_discounts.quantity_threshold").group("invoice_items.id").pluck(:id)
    ids.include?(item.invoice_items.first.id)
  end

  def calculate_discounted_wholeinvoice_revenue
    discount = invoice_items.joins(:bulk_discounts).select("invoice_items.id, (invoice_items.quantity * invoice_items.unit_price) * max(bulk_discounts.percentage_discount * .01) as remaining_revenue").where("invoice_items.quantity >= bulk_discounts.quantity_threshold").group("invoice_items.id").sum(&:remaining_revenue).to_i 
    calculate_invoice_revenue - discount
  end

end
