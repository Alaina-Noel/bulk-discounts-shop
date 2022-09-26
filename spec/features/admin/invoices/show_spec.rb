require 'rails_helper'

RSpec.describe 'admin invoice show' do
    let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}
    let!(:carly_silo) { Merchant.create!(name: "Carly Candy Silo")}

    let!(:jcity_discount1) {jewlery_city.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)}
    let!(:jcity_discount2) {jewlery_city.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 15)}
    
    let!(:gold_earrings) { jewlery_city.items.create!(name: "Gold Earrings", description: "14k Gold 12' Hoops", unit_price: 12000) }
    let!(:silver_necklace) { jewlery_city.items.create!(name: "Silver Necklace", description: "An everyday wearable silver necklace", unit_price: 22000) }
    let!(:studded_bracelet) { jewlery_city.items.create!(name: "Studded Bracelet", description: "A dainty studded bracelet", unit_price: 1100) }
    let!(:candy_canes) { carly_silo.items.create!(name: "Candy", description: "A dainty studded bracelet", unit_price: 4500) }

    let!(:alaina) { Customer.create!(first_name: "Alaina", last_name: "Kneiling")}
    let!(:alaina_invoice1) { alaina.invoices.create!(status: "completed")}

    let!(:alainainvoice1_itemgold_earrings) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: gold_earrings.id, quantity: 12, unit_price: 1300, status:"packaged" )}
    let!(:alainainvoice1_itemsilver_necklace) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: silver_necklace.id, quantity: 15, unit_price: 1300, status:"packaged" )}
    let!(:alainainvoice1_itemstudded_bracelet) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: studded_bracelet.id, quantity: 1, unit_price: 1100, status:"packaged" )}
    let!(:alainainvoice1_itemcandy) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: candy_canes.id, quantity: 1, unit_price: 1100, status:"packaged" )}

    it 'shows all invoice info including two revenues: one with the discount and one without' do
        visit admin_invoice_path(alaina_invoice1)
        expect(page).to have_content("##{alaina_invoice1.id}")
        expect(page).to have_content("#{alaina_invoice1.status}")
        expect(page).to have_content("Created at: #{alaina_invoice1.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{alaina.name}")
        expect(page).to have_content(sprintf("%.2f",alaina_invoice1.calculate_invoice_revenue/100.to_f))
        expect(page).to have_content(sprintf("%.2f",alaina_invoice1.calculate_discounted_wholeinvoice_revenue/100.to_f))
    end

    describe 'invoice items' do
        it 'shows all invoice items' do
            visit admin_invoice_path(alaina_invoice1)
            within "#invoice_items" do
                expect(page).to have_content(alainainvoice1_itemgold_earrings.item.name)
                expect(page).to have_content(alainainvoice1_itemsilver_necklace.item.name)
                expect(page).to have_content(alainainvoice1_itemstudded_bracelet.item.name)
                expect(page).to have_content(alainainvoice1_itemcandy.item.name)
            end
        end

        it 'shows all item info' do
            visit admin_invoice_path(alaina_invoice1)
            expect(page).to have_content(alainainvoice1_itemgold_earrings.item.name)
            expect(page).to have_content("#{alainainvoice1_itemgold_earrings.quantity}")
            expect(page).to have_content(sprintf("%.2f",alainainvoice1_itemgold_earrings.unit_price/100.to_f))
            expect(page).to have_content("#{alainainvoice1_itemgold_earrings.status}")
        end
    end

    it 'invoice status is a select field and can be updated' do
        visit admin_invoice_path(alaina_invoice1)

        expect(alaina_invoice1.status).to eq('completed')
        within("#invoice_info") do
            select "in_progress", from: "invoice_status"
            click_button('Update Invoice')
            alaina_invoice1.reload
            expect(alaina_invoice1.status).to eq('in_progress')
        end
    end

end
