require 'rails_helper'

RSpec.describe 'Merchant Index Show Page' do

  let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}
  
  let!(:jcity_discount1) {jewlery_city.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)}
  let!(:jcity_discount2) {jewlery_city.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 15)}
  
  let!(:gold_earrings) { jewlery_city.items.create!(name: "Gold Earrings", description: "14k Gold 12' Hoops", unit_price: 12000000) }
  let!(:silver_necklace) { jewlery_city.items.create!(name: "Silver Necklace", description: "An everyday wearable silver necklace", unit_price: 22000) }
  let!(:studded_bracelet) { jewlery_city.items.create!(name: "Studded Bracelet", description: "A dainty studded bracelet", unit_price: 1100) }

  let!(:alaina) { Customer.create!(first_name: "Alaina", last_name: "Kneiling")}
  let!(:alaina_invoice1) { alaina.invoices.create!(status: "completed")}

  let!(:alainainvoice1_itemgold_earrings) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: gold_earrings.id, quantity: 12, unit_price: 1300, status:"packaged" )}
  let!(:alainainvoice1_itemsilver_necklace) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: silver_necklace.id, quantity: 15, unit_price: 1300, status:"packaged" )}
  let!(:alainainvoice1_itemstudded_bracelet) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: studded_bracelet.id, quantity: 1, unit_price: 1100, status:"packaged" )}
  
  describe 'when I visit a merchant invoice show page' do
    describe 'I see information related to the invoice' do
      it 'displays id number, status, date of creation, customer full name' do
        visit merchant_invoice_path(jewlery_city, alaina_invoice1)

        expect(page).to have_content("Invoice ##{alaina_invoice1.id}")
        expect(page).to have_content("Status: #{alaina_invoice1.status}")
        expect(page).to have_content("Created at: #{alaina_invoice1.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{alaina.name}")
      end
    end

    describe 'I see all of MY items on the invoice' do

      it 'displays the name of each merchant item on the invoice' do
        visit merchant_invoice_path(jewlery_city, alaina_invoice1)
        within("#invoice_items") do
          expect(page).to have_content(silver_necklace.name)
          expect(page).to have_content(gold_earrings.name)
        end
        expect(page).to have_content("Invoice ##{alaina_invoice1.id}")

        within("#invoice_items") do
          expect(page).to have_content(gold_earrings.name)
          expect(page).to have_content(silver_necklace.name)
          expect(page).to have_content(studded_bracelet.name)
        end
      end

      it 'displays the quantity, sale price, and status for each item' do
        visit merchant_invoice_path(jewlery_city, alaina_invoice1)
        within("#item_#{gold_earrings.id}") do
          expect(page).to have_content("#{alainainvoice1_itemgold_earrings.quantity}")
          expect(page).to have_content("#{((alainainvoice1_itemgold_earrings.unit_price)/100.to_f).round(2)}")
          expect(page).to have_field("Status", with: alainainvoice1_itemgold_earrings.status)
        end

        within("#item_#{silver_necklace.id}") do
          expect(page).to have_content("#{alainainvoice1_itemsilver_necklace.quantity}")
          expect(page).to have_content("#{((alainainvoice1_itemsilver_necklace.unit_price)/100.to_f).round(2)}")
          expect(page).to have_field("Status", with: alainainvoice1_itemsilver_necklace.status)
        end
      end
      
      describe 'when I change an items status and click the submit button' do
        it 'takes me back to the merchant invoice show page and shows the updated status' do
          visit merchant_invoice_path(jewlery_city, alaina_invoice1)

          within("#item_#{gold_earrings.id}") do
            expect(page).to have_field("Status", with: "packaged")
            select "shipped", from: :status
            click_on "Update Item Status"
          end

          expect(current_path).to eq merchant_invoice_path(jewlery_city, alaina_invoice1)

          within("#item_#{gold_earrings.id}") do
            expect(page).to have_field("Status", with: "shipped")
          end
        end
      end

     it 'Then I see the total revenue that will be generated from all of my items on the invoice' do
        visit merchant_invoice_path(jewlery_city, alaina_invoice1)

        within("#total_invoice_revenue") do

          expect(page).to have_content("Total Revenue From This Invoice: $#{sprintf("%.2f",alaina_invoice1.calculate_revenue_for(jewlery_city)/100.to_f)}")
        end
      end

      it 'Then I see two total revenue for my merchant from this invoice one with the discount and one without the discount' do
        visit merchant_invoice_path(jewlery_city, alaina_invoice1)

        within("#total_invoice_revenue") do
          expect(page).to have_content("Total Revenue From This Invoice Discount Applied: $#{sprintf("%.2f",alaina_invoice1.calculate_discounted_invoice_revenue(jewlery_city)/100.to_f)}")
        end
      end


      it 'Next to each invoice item I see a link to the show page for the bulk discount that was applied (if any)' do
        visit merchant_invoice_path(jewlery_city, alaina_invoice1)
        
        within("#item_#{studded_bracelet.id}") do
          expect(page).to_not have_link("View Details")
        end
        
        within("#item_#{gold_earrings.id}") do
          expect(page).to have_link("View Details")
          click_on("View Details")
          expect(current_path).to eq(merchant_bulk_discount_path(jewlery_city, jcity_discount1))
        end
        
      end



    end
  end
end

