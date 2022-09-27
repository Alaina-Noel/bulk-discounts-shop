require 'rails_helper'

RSpec.describe 'merchant bulk discount show page', type: :feature do
  describe 'As a visitor' do
    describe 'When I visit my bulk discount show page' do
      let!(:carly_silo) { Merchant.create!(name: "Carly Simon's Candy Silo")}
      let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}

      let!(:carlys_discount1) {carly_silo.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)}
      let!(:carlys_discount2) {carly_silo.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 15)}
      let!(:carlys_discount3) {carly_silo.bulk_discounts.create!(percentage_discount: 40, quantity_threshold: 5)}

      it "Then I see the bulk discount's quantity threshold and percentage discount" do

        visit merchant_bulk_discount_path(carly_silo, carlys_discount1)

        expect(page).to have_content("Discount Percentage: %#{carlys_discount1.percentage_discount}")
        expect(page).to have_content("Quantity: #{carlys_discount1.quantity_threshold}")
        expect(page).to_not have_content("Discount Percentage: %#{carlys_discount2.percentage_discount}")
        expect(page).to_not have_content("Quantity: #{carlys_discount2.quantity_threshold}")
      end

      it "Then I see a link to edit the bulk discount & when I click this link, then I am taken to a new page with a form to edit the discount" do

        visit merchant_bulk_discount_path(carly_silo, carlys_discount1)

        within('#edit_discount') do 
          expect(page).to have_link("Edit")
          click_link("Edit")
        end
        expect(current_path).to eq(edit_merchant_bulk_discount_path(carly_silo, carlys_discount1))
        expect(page).to have_content("Quantity")
        expect(page).to have_content("Percent Off")
      end

      it "And I see that the discounts current attributes are pre-poluated in the form" do
       
        visit edit_merchant_bulk_discount_path(carly_silo, carlys_discount1)

        expect(page).to have_field("Quantity", with: "#{carlys_discount1.quantity_threshold}")
        expect(page).to have_field("Percent Off", with: "#{carlys_discount1.percentage_discount}")

      end

      it "When I change any/all of the information and click submit, I am redirected to the bulk discount's show page & I see that the discount's attributes have been updated" do
        
        visit edit_merchant_bulk_discount_path(carly_silo, carlys_discount1)
        select('%99', from: :percentage_discount)
        fill_in('Quantity', with: 99)
        click_on "Save"

        expect(current_path).to eq(merchant_bulk_discount_path(carly_silo, carlys_discount1))

        expect(page).to have_content("%99")
        expect(page).to have_content(99)
      end

      it "When I fill in the quantity with anything but an integer I am redirected to the same page" do #edge case
        
        visit new_merchant_bulk_discount_path(carly_silo)

        select('%98', from: :percentage_discount)
        fill_in('Quantity', with: "e")
        click_on "Save"

        expect(current_path).to eq(new_merchant_bulk_discount_path(carly_silo))

        expect(page).to_not have_content("Quantity of Items: 3")
      end

      it "When I change any/all of the information to invalid data and click submit the new data has not been saved." do #edge case
        
        visit edit_merchant_bulk_discount_path(carly_silo, carlys_discount1)

        select('%99', from: :percentage_discount)
        fill_in('Quantity', with: 1.2)
        click_on "Save"

        expect(page).to have_content("%99")
        expect(page).to_not have_content(1.2)

        visit merchant_bulk_discount_path(carly_silo, carlys_discount1)
        expect(page).to_not have_content(1.2)
        expect(page).to have_content("%99")
      end




    end
  end
end
