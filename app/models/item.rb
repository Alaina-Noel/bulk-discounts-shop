class Item < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true
  
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices
  has_many :bulk_discounts, through: :merchant

  def best_sales_date
    date = self.invoices.select(:created_at, "invoice_items.unit_price*quantity as revenue").order("revenue desc", "invoices.created_at desc").first.created_at
    date.strftime("%B %d, %Y")
  end

  def invoice_item(invoice)
    InvoiceItem.select("invoice_items.*").where(item_id: self.id, invoice_id: invoice.id).order(created_at: :desc).first
  end

  def discount_applied?
    applied_discounts = merchant.invoice_items.joins(:bulk_discounts).select("invoice_items.id, (invoice_items.quantity * invoice_items.unit_price) * min(1 - (bulk_discounts.percentage_discount * .01)) as remaining_revenue").where("invoice_items.quantity >= bulk_discounts.quantity_threshold").group("invoice_items.id").pluck("invoice_items.id")
    !self.invoice_items.where(id: applied_discounts).empty?
  end
end