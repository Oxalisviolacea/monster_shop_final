require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Cart Show Page' do
  describe 'As a Visitor' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @m_user = User.create!(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword', merchant_id: @megan.id)
      
      visit '/login'
      fill_in 'Email', with: @m_user.email  
      fill_in 'Password', with: @m_user.password
      click_button 'Log In'

      visit '/merchant/discounts'
      click_link 'New Bulk Discount'
      fill_in :amount, with: '5'
      fill_in :quantity, with: '3'
      click_on 'Submit'
      @discount_1 = Discount.last

      visit '/merchant/discounts'
      click_link 'New Bulk Discount'
      fill_in :amount, with: '5'
      fill_in :quantity, with: '3'
      click_on 'Submit'
      @discount_2 = Discount.last
    end       
       
    it 'I can see the subtotal including the discount, for item in my order' do
      visit item_path(@ogre)
      click_button 'Add to Cart'

      visit '/cart'
      within "#item-#{@ogre.id}" do
        click_button('More of This!')
        click_button('More of This!')
        expect(page).to have_content("Discount: #{@discount_2.amount}% off!")
        expect(page).to have_content('Subtotal: $57.00')
      end

      click_button 'Check Out'

      order = Order.last
      visit "/profile/orders/#{order.id}"

      expect(page).to have_link(@ogre.name)
      expect(page).to have_content("Quantity: 3")
      expect(page).to have_content("Price: $19.00")
      expect(page).to have_content("Total: $57.00")
    end

    it 'if I add multiple items to my order it will calculate the total cost' do
      visit item_path(@ogre)
      click_button 'Add to Cart'

      visit item_path(@giant)
      click_button 'Add to Cart'

      visit '/cart'
      within "#item-#{@ogre.id}" do
        click_button('More of This!')
        click_button('More of This!')
      end

      click_button 'Check Out'

      order = Order.last
      visit "/profile/orders/#{order.id}"

      expect(page).to have_content("Total: $107.00")
      expect(page).to have_link(@ogre.name)
      expect(page).to have_content("Quantity: 3")
      expect(page).to have_content("Price: $19.00")
    end
  end
end