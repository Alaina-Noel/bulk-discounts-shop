require 'rails_helper'

RSpec.describe 'bulk discount index page', type: :feature do
  describe 'As a visitor' do
    describe 'When I visit the bulk discount index page' do
      let!(:carly_silo) { Merchant.create!(name: "Carly Simon's Candy Silo")}
      let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}

      let!(:carlys_discount1) {carly_silo.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)}
      let!(:carlys_discount2) {carly_silo.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 15)}
      let!(:carlys_discount3) {carly_silo.bulk_discounts.create!(percentage_discount: 40, quantity_threshold: 5)}

      it 'I see all of my bulk discounts including their percentage discount and quantity thresholds' do

        visit "/merchants/#{carly_silo.id}/bulk_discounts"

        within("#discount_#{carlys_discount1.id}") do 
          expect(page).to have_content("Discount ##{carlys_discount1.id}")
          expect(page).to have_content("Percentage Off: %#{carlys_discount1.percentage_discount}")
          expect(page).to have_content("Quantity of Items: #{carlys_discount1.quantity_threshold}")
          expect(page).to_not have_content("Quantity of Items: #{carlys_discount2.quantity_threshold}")

        end
      end

      it 'And each bulk discount listed includes a link to its show page' do

        visit "/merchants/#{carly_silo.id}/bulk_discounts"
        
        within("#discount_#{carlys_discount1.id}") do 
        expect(page).to have_link('View this Discount')
        click_link('View this Discount')
        end

        expect(current_path).to eq(merchant_bulk_discount_path(carly_silo, carlys_discount1.id))
      end

      it 'Then I see a link to create a new discount & When I click this link I am taken to a new page where I see a form to add a new bulk discount' do

        visit "/merchants/#{carly_silo.id}/bulk_discounts"
        expect(page).to have_link("Create a New Discount")
        click_link("Create a New Discount")

        expect(current_path).to eq("/merchants/#{carly_silo.id}/bulk_discounts/new")
        expect(page).to have_content("Percent Off")
        expect(page).to have_content("Quantity")
      end

      it 'When I fill in the form with valid data & I am redirected back to the bulk discount index &  I see my new bulk discount listed' do

        visit new_merchant_bulk_discount_path(carly_silo)

        select('%42', from: :percentage_discount)
        fill_in('Quantity', with: 22)
        click_on "Save"

        expect(current_path).to eq("/merchants/#{carly_silo.id}/bulk_discounts")

        expect(page).to have_content("%42")
        expect(page).to have_content(22)
      end

      it 'Then next to each bulk discount I see a link to delete it, when I click this link, I am redirected back to the bulk discounts index page, & I no longer see the discount listed' do

        visit "/merchants/#{carly_silo.id}/bulk_discounts"

        expect(page).to have_content("Discount ##{carlys_discount1.id}")
        expect(page).to have_content("Percentage Off: %#{carlys_discount1.percentage_discount}")
        expect(page).to have_content("Quantity of Items: #{carlys_discount1.quantity_threshold}")

        within("#discount_#{carlys_discount1.id}") do 
          expect(page).to have_button("Delete")
          click_on("Delete")
        end

        expect(current_path).to eq("/merchants/#{carly_silo.id}/bulk_discounts")
        expect(page).to_not have_content("Discount ##{carlys_discount1.id}")
        expect(page).to_not have_content("Percentage Off: %#{carlys_discount1.percentage_discount}")
        expect(page).to_not have_content("Quantity of Items: #{carlys_discount1.quantity_threshold}")
      end

      it 'I see a section with a header of "Upcoming Holidays" In this section the name and date of the next 3 upcoming US holidays are listed.' do

        visit merchant_bulk_discounts_path(carly_silo)
        
        expect(page).to have_content("Upcoming Holidays")
        expect(page).to have_content("Columbus Day")
        expect(page).to have_content("Veterans Day")
        expect(page).to have_content("Thanksgiving Day")
      end
    end
  end
end


