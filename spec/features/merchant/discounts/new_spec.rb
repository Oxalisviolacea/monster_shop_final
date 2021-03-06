require 'rails_helper'

RSpec.describe 'Merchant Discounts New Page' do
  describe 'As an employee of a merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @m_user = @merchant_1.users.create(name: 'Megan', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'megan@example.com', password: 'securepassword')
      @ogre = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20.25, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @merchant_1.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @merchant_2.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 1 )
      @order_1 = @m_user.orders.create!(status: "pending")
      @order_2 = @m_user.orders.create!(status: "pending")
      @order_3 = @m_user.orders.create!(status: "pending")
      @order_item_1 = @order_1.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: false)
      @order_item_2 = @order_2.order_items.create!(item: @hippo, price: @hippo.price, quantity: 2, fulfilled: true)
      @order_item_3 = @order_2.order_items.create!(item: @ogre, price: @ogre.price, quantity: 2, fulfilled: false)
      @order_item_4 = @order_3.order_items.create!(item: @giant, price: @giant.price, quantity: 2, fulfilled: false)
      @discount_1 = @merchant_1.discounts.create!(quantity: 2, amount: 5)
      @discount_2 = @merchant_1.discounts.create!(quantity: 5, amount: 10)
      @discount_2 = @merchant_1.discounts.create!(quantity: 5, amount: 10)
      
      visit '/login'
      fill_in 'Email', with: @m_user.email  
      fill_in 'Password', with: @m_user.password
      click_button 'Log In'
    end

    it 'I can create a new discount' do
      visit '/merchant/discounts/new'

      fill_in :amount, with: '30'
      fill_in :quantity, with: '25'
      click_on 'Submit'

      expect(current_path).to eq('/merchant/discounts')

      new_discount = Discount.last

      expect(new_discount.quantity).to eq(25)
      expect(new_discount.amount).to eq(30)
    end

    it 'if I incorrectly fill out the discount form I will see a flash message' do
      visit '/merchant/discounts/new'

      fill_in :amount, with: ''
      fill_in :quantity, with: ''
      click_on 'Submit'

      expect(page).to have_content("Quantity can't be blank, Amount can't be blank, and Amount is not a number")
    end
  end
end